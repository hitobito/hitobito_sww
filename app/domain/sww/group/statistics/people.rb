# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Sww::Group::Statistics
  class People < ::Group::Statistics::Base
    self.key = :people
    self.permitted_params = [:date, :selected_group_id]

    ABO_TAG_PREFIX = "abo:"

    AGE_BUCKET_SIZE = 10
    AGE_BUCKET_NIL_SORT_VALUE = 10_000

    include GroupScoping

    Bucket = Data.define(:label, :count, :percent)

    validates_date :date, allow_blank: true

    attr_reader :date, :stichtag, :person

    def initialize(...)
      super
      @date = filter_params[:date] # kept seperately for validation
      @stichtag = parse_date(@date) || Time.zone.today
      @selected_group_id = filter_params[:selected_group_id].to_i
      @person = Person.new # we want Person's methods but avoid loading (many) people
    end

    def selected_group
      @selected_group ||= selectable_groups.index_by(&:id)[@selected_group_id] || layer
    end

    def total_count
      @total_count ||= people.count
    end

    def magazine_subscribers_count
      @magazine_subscribers_count ||= count_subscribed_people
    end

    def language_breakdown
      @language_breakdown ||= build_breakdown(:language)
    end

    def gender_breakdown
      @gender_breakdown ||= build_breakdown(:gender)
    end

    def age_groups
      @age_groups ||= build_age_groups
    end

    def selectable_groups
      @selectable_groups ||= layer.self_and_descendants.merge(::Group.layers).to_a
    end

    def selectable_groups_without_selected
      selectable_groups - [selected_group]
    end

    private

    alias_method :scoping_root, :selected_group

    def people
      @people ||= ::Person.where(id: person_ids_scope)
    end

    def count_subscribed_people
      people_today = ::Person.joins(:roles).where(roles: {group_id: group_ids}).distinct
      people_today
        .joins(:tags)
        .where("tags.name LIKE ?", "#{ABO_TAG_PREFIX}%")
        .distinct
        .count
    end

    def person_ids_scope
      active_role_scope = Role.active(stichtag).where(
        "roles.archived_at IS NULL OR roles.archived_at > ?", stichtag
      )
      ::Person
        .joins(:roles_unscoped)
        .merge(active_role_scope)
        .where(roles: {group_id: group_ids})
        .select(:id)
    end

    def build_breakdown(attribute)
      sorted_tally(people.pluck(attribute), &:to_s).map do |value, count, percent|
        Bucket.new(label: person.public_send(:"#{attribute}_label", value), count:, percent:)
      end
    end

    def build_age_groups
      buckets = sorted_tally(age_buckets) { |bucket| bucket || AGE_BUCKET_NIL_SORT_VALUE }
      buckets.map do |min_age, count, percent|
        Bucket.new(label: age_bucket_label(min_age), count:, percent:)
      end
    end

    def sorted_tally(values, &sort_key)
      counts = values.tally
      total = counts.values.sum.to_f
      sorted = counts.sort_by { |value, _count| sort_key.call(value) }

      sorted.map do |min_age, count|
        percentage = count / total * 100
        [min_age, count, percentage]
      end
    end

    def age_buckets
      people.pluck(:birthday).map do |birthday|
        next if birthday.blank?
        person.birthday = birthday

        (person.years(stichtag) / AGE_BUCKET_SIZE) * AGE_BUCKET_SIZE
      end
    end

    def age_bucket_label(min_age)
      "#{min_age}-#{min_age + AGE_BUCKET_SIZE - 1}" if min_age
    end
  end
end
