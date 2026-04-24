# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Sww::Group::Statistics::EventParticipation do
  let(:layer) { groups(:berner_wanderwege) }

  def statistic(params = {})
    described_class.new(layer, ActionController::Parameters.new(params))
  end

  def create_event_in_layer(start_at: Time.zone.today)
    Fabricate(:event, groups: [layer],
      dates: [Event::Date.new(start_at: start_at, finish_at: start_at + 1.day)])
  end

  describe "validations" do
    it "is valid with no params" do
      expect(statistic).to be_valid
    end

    it "is valid with blank date params" do
      expect(statistic(from: "", to: "")).to be_valid
    end

    it "is valid with valid from and to dates" do
      expect(statistic(from: "01.01.2024", to: "31.12.2024")).to be_valid
    end

    it "is valid when from equals to" do
      expect(statistic(from: "15.06.2024", to: "15.06.2024")).to be_valid
    end

    it "is invalid when from is not a valid date" do
      s = statistic(from: "not-a-date")
      expect(s).not_to be_valid
      expect(s.errors[:from]).to be_present
    end

    it "is invalid when to is not a valid date" do
      s = statistic(to: "32.13.2024")
      expect(s).not_to be_valid
      expect(s.errors[:to]).to be_present
    end

    it "is invalid when from is after to" do
      s = statistic(from: "31.12.2024", to: "01.01.2024")
      expect(s).not_to be_valid
      expect(s.errors[:to]).to be_present
    end

    it "is valid when from is before to" do
      expect(statistic(from: "01.01.2024", to: "31.12.2024")).to be_valid
    end

    it "does not validate to against from when from is blank" do
      expect(statistic(from: "", to: "01.01.2024")).to be_valid
    end
  end

  describe "#from_date" do
    it "defaults to January 1st of current year" do
      expect(statistic.from_date).to eq(Time.zone.today.beginning_of_year)
    end

    it "parses date from param" do
      expect(statistic(from: "01.01.2024").from_date).to eq(Date.new(2024, 1, 1))
    end

    it "falls back to default for invalid date" do
      expect(statistic(from: "not-a-date").from_date).to eq(Time.zone.today.beginning_of_year)
    end
  end

  describe "#to_date" do
    it "defaults to December 31st of current year" do
      expect(statistic.to_date).to eq(Time.zone.today.end_of_year)
    end

    it "parses date from param" do
      expect(statistic(to: "31.12.2024").to_date).to eq(Date.new(2024, 12, 31))
    end
  end

  describe "#include_sublayers?" do
    it "is true by default (no param)" do
      expect(statistic.include_sublayers?).to be true
    end

    it "is true when param is 'true'" do
      expect(statistic(include_sublayers: "true").include_sublayers?).to be true
    end

    it "is false when param is 'false'" do
      expect(statistic(include_sublayers: "false").include_sublayers?).to be false
    end
  end

  describe "calculations" do
    let(:layer) { groups(:berner_wanderwege) }
    let(:event) { create_event_in_layer }
    let(:member) { people(:berner_wanderer) }
    let(:non_member) { people(:zuercher_wanderer) }
    let(:guest) { Fabricate.build(:event_guest) }

    before do
      member_participation = Fabricate(:event_participation, event: event, participant: member,
        active: true)
      Fabricate(:event_participation, event: event, participant: non_member, active: true)
      Fabricate(:event_participation, event: event, participant: Fabricate(:person), active: false)
      guest.update!(main_applicant: member_participation)
      Fabricate(:event_participation, event: event, participant: guest, active: true)
    end

    describe "#events_count" do
      it "counts events in date range belonging to layer" do
        expect(statistic.events_count).to eq(1)
      end

      it "does not count events outside date range" do
        Fabricate(:event, groups: [layer],
          dates: [Event::Date.new(start_at: 2.years.ago, finish_at: 2.years.ago + 1.day)])
        expect(statistic.events_count).to eq(1)
      end
    end

    describe "#total_participations" do
      it "counts active participations including guests" do
        expect(statistic.total_participations).to eq(3)
      end
    end

    describe "#participations_with_membership" do
      it "counts participants with active role in the layer" do
        expect(statistic.participations_with_membership).to eq(1)
      end

      it "does not count a role that was archived before the event" do
        member.roles.update_all(archived_at: event.start_at - 1.day)
        expect(statistic.participations_with_membership).to eq(0)
      end
    end

    describe "#participations_without_membership" do
      it "is total minus members minus guests" do
        expect(statistic.participations_without_membership).to eq(1)
      end

      it "counts a participant whose role was archived before the event as non-member" do
        member.roles.update_all(archived_at: event.start_at - 1.day)
        expect(statistic.participations_without_membership).to eq(2)
      end
    end

    describe "#unique_participants_count" do
      it "counts each person only once across all events" do
        expect(statistic.unique_participants_count).to eq(2)
        event2 = create_event_in_layer
        Fabricate(:event_participation, event: event2, participant: member, active: true)
        expect(statistic.unique_participants_count).to eq(2)
      end
    end

    describe "#average_participants" do
      it "computes total participations divided by event count" do
        expect(statistic.total_participations).to eq(3)
        expect(statistic.events_count).to eq(1)
        expect(statistic.average_participants).to eq(3.0)

        event2 = create_event_in_layer
        Fabricate(:event_participation, event: event2, participant: member, active: true)
        expect(statistic.events_count).to eq(2)
        expect(statistic.average_participants).to eq(2.0)
      end
    end

    describe "#participations_guests" do
      it "counts the guests" do
        expect(statistic.participations_guests).to eq(1)
      end

      it "counts additional active Event::Guest participations" do
        guest = Fabricate(:event_guest, main_applicant: member.event_participations.first)
        Fabricate(:event_participation, event: event, participant: guest, active: true)
        expect(statistic.participations_guests).to eq(2)
      end

      it "does not count inactive Event::Guest participations" do
        guest = Fabricate(:event_guest, main_applicant: member.event_participations.first)
        Fabricate(:event_participation, event: event, participant: guest, active: false)
        expect(statistic.participations_guests).to eq(1)
      end
    end

    describe "#participation_frequency" do
      it "returns how many persons attended n events" do
        # member: 1 event, non_member: 1 event → {1 => 2}
        expect(statistic.participation_frequency).to eq({1 => 2})
      end

      it "groups correctly when persons attend different numbers of events" do
        event2 = create_event_in_layer
        Fabricate(:event_participation, event: event2, participant: member, active: true)
        # member: 2 events, non_member: 1 event
        expect(statistic.participation_frequency).to eq({1 => 1, 2 => 1})
      end
    end
  end
end
