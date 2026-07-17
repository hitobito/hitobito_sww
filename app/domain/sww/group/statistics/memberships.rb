# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Sww::Group::Statistics
  class Memberships < ::Group::Statistics::Base
    self.key = :memberships
    self.layer_only = false

    include DateRangeFilter

    TotalRow = Data.define(:entries, :exits, :net, :count) do
      def blank? = entries.zero? && exits.zero? && count.zero?
    end
    RoleRow = Data.define(:label, :entries, :exits, :net, :count)
    GroupBreakdown = Data.define(:title, :role_rows, :total_row)

    def total_entries
      @total_entries ||= entries_scope.where(group_id: groups.map(&:id)).count
    end

    def total_exits
      @total_exits ||= exits_scope.where(group_id: groups.map(&:id)).count
    end

    def net_change
      total_entries - total_exits
    end

    def total_count
      @total_count ||= actives_scope.where(group_id: groups.map(&:id)).count
    end

    def group_breakdowns
      @group_breakdowns ||= groups.map { |group| build_group_breakdown(group) }
        .reject { |breakdown| breakdown.total_row.blank? }
    end

    private

    def build_group_breakdown(group)
      title = breadcrumb_title(group)
      role_rows = build_role_rows(group)
      total_row = TotalRow.new(
        entries: role_rows.sum(&:entries),
        exits: role_rows.sum(&:exits),
        net: role_rows.sum(&:net),
        count: role_rows.sum(&:count)
      )
      GroupBreakdown.new(title:, role_rows:, total_row:)
    end

    def breadcrumb_title(current_group)
      if current_group == group
        "#{group} #{I18n.t("group.statistics.memberships.layer_only_suffix")}"
      else
        current_group.local_hierarchy[1..].map(&:to_s).join(" → ")
      end
    end

    def build_role_rows(current_group)
      role_types_in(current_group.id).map do |role_type|
        build_role_row(current_group.id, role_type)
      end
    end

    def role_types_in(group_id)
      keys = entries_by_group_and_type.keys +
        exits_by_group_and_type.keys +
        actives_by_group_and_type.keys

      keys.filter_map { |id, role_type| role_type if id == group_id }.uniq
    end

    def build_role_row(group_id, type)
      entries = entries_by_group_and_type.fetch([group_id, type], 0)
      exits = exits_by_group_and_type.fetch([group_id, type], 0)
      net = entries - exits
      count = actives_by_group_and_type.fetch([group_id, type], 0)
      RoleRow.new(label: type.constantize.label, entries:, exits:, net:, count:)
    end

    def groups
      @groups ||= group.self_and_descendants.where(layer_group_id: layer.id).order(:lft).to_a
    end

    def entries_by_group_and_type
      @entries_by_group_and_type ||= entries_scope.group(:group_id, :type).count
    end

    def exits_by_group_and_type
      @exits_by_group_and_type ||= exits_scope.group(:group_id, :type).count
    end

    def actives_by_group_and_type
      @actives_by_group_and_type ||= actives_scope.group(:group_id, :type).count
    end

    def entries_scope
      ::Role.with_inactive.where(start_on: from_date..to_date)
    end

    def exits_scope
      ::Role.with_inactive.where(end_on: from_date..to_date)
    end

    def actives_scope
      ::Role.active(to_date)
    end
  end
end
