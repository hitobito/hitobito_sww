# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Sww::Group::Statistics
  class EventParticipation < ::Group::Statistics::Base
    self.key = :event_participation
    self.permitted_params = [:from, :to, :include_sublayers]

    validates_date :from, allow_blank: true
    validates_date :to, allow_blank: true
    validates_date :to, on_or_after: :from,
      on_or_after_message: :date_range_invalid,
      if: -> { filter_params[:from].present? && errors[:to].none? }

    def events_count
      @events_count ||= events.count
    end

    # Total number of participations: persons and guests, active = true
    def total_participations
      @total_participations ||= filtered_participations.count
    end

    # Number of members: participants with at least one active role in the relevant groups
    # at the time of the event (archived_at is compared with event_dates.start_at)
    def participations_with_membership
      @participations_with_membership ||= person_participations
        .joins(event: :dates)
        .joins("INNER JOIN roles ON roles.person_id = event_participations.participant_id" \
               " AND (roles.archived_at IS NULL OR roles.archived_at > event_dates.start_at)")
        .joins("INNER JOIN groups role_groups ON role_groups.id = roles.group_id")
        .where(role_groups: {id: group_ids})
        .distinct
        .count
    end

    def participations_without_membership
      total_participations - participations_with_membership - participations_guests
    end

    # Number of unique persons (each person counted only once)
    def unique_participants_count
      @unique_participants_count ||= person_participations.distinct.count(:participant_id)
    end

    # Average number of participants per event
    def average_participants
      return 0.0 if events_count.zero?
      (total_participations.to_f / events_count)
    end

    # Guests: participant_type == 'Event::Guest'
    def participations_guests
      @participations_guests ||= filtered_participations
        .where(participant_type: "Event::Guest")
        .count
    end

    # How many persons attended n events: { 1 => 390, 2 => 20, ... }
    def participation_frequency
      @participation_frequency ||= begin
        counts = person_participations
          .group(:participant_id)
          .distinct
          .count(:event_id)
        counts.values.tally.sort.to_h
      end
    end

    def from_date
      @from_date ||= parse_date(filter_params[:from]) || Time.zone.today.beginning_of_year
    end

    def to_date
      @to_date ||= parse_date(filter_params[:to]) || Time.zone.today.end_of_year
    end

    def from
      filter_params[:from]
    end

    def to
      filter_params[:to]
    end

    def include_sublayers?
      filter_params[:include_sublayers].to_s != "false"
    end

    private

    def events
      @events ||= Event.joins(:groups)
        .where(groups: {id: group_ids})
        .between(from_date, to_date.end_of_day) # Event.between calls distinct
    end

    def filtered_participations
      @filtered_participations ||= Event::Participation
        .active
        .joins(:event)
        .where(events: {id: events.select(:id)})
    end

    def person_participations
      filtered_participations.where(participant_type: "Person")
    end

    def parse_date(value)
      return nil if value.blank?
      Date.parse(value)
    rescue Date::Error, TypeError
      nil
    end

    def group_ids
      @group_ids ||= if include_sublayers?
        layer.self_and_descendants.pluck(:id)
      else
        layer.groups_in_same_layer.pluck(:id)
      end
    end
  end
end
