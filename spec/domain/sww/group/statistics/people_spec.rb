# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Sww::Group::Statistics::People do
  let(:layer) { groups(:berner_wanderwege) }

  def statistic(params = {})
    described_class.new(layer, ActionController::Parameters.new(params))
  end

  describe "validations" do
    it "is valid with no params" do
      expect(statistic).to be_valid
    end

    it "is valid with a blank date param" do
      expect(statistic(date: "")).to be_valid
    end

    it "is valid with a valid date" do
      expect(statistic(date: "01.01.2024")).to be_valid
    end

    it "is invalid when date is not a valid date" do
      s = statistic(date: "not-a-date")
      expect(s).not_to be_valid
      expect(s.errors[:date]).to be_present
    end
  end

  describe "layer_only" do
    it "is disabled, so a non-layer group can be used" do
      expect(described_class.layer_only).to be false
      expect { described_class.new(groups(:berner_mitglieder)) }.not_to raise_error
    end
  end

  describe "#stichtag" do
    it "defaults to today" do
      expect(statistic.stichtag).to eq(Time.zone.today)
    end

    it "parses the date from the param" do
      expect(statistic(date: "01.01.2024").stichtag).to eq(Date.new(2024, 1, 1))
    end

    it "falls back to today for an invalid date" do
      expect(statistic(date: "not-a-date").stichtag).to eq(Time.zone.today)
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

  describe "group scoping" do
    let(:layer) { groups(:schweizer_wanderwege) }
    let(:member) { people(:berner_wanderer) }

    it "counts everyone below the layer by default" do
      expect(statistic.total_count).to eq(4)
    end

    it "excludes people from other layers when include_sublayers is false" do
      s = statistic(include_sublayers: "false")
      expect(s.total_count).to eq(0)
    end
  end

  describe "calculations" do
    let(:layer) { groups(:berner_wanderwege) }
    let(:member) { people(:berner_wanderer) }
    let(:other_member) { people(:no_permissions) }

    describe "#total_count" do
      it "counts people with an active role in the layer hierarchy" do
        expect(statistic.total_count).to eq(2)
      end

      it "does not count a person only once when they hold multiple roles in scope" do
        Fabricate(Group::Kontakte::Kontakt.sti_name.to_sym,
          person: member, group: groups(:berner_kontakte))
        expect(statistic.total_count).to eq(2)
      end

      it "does not count a role that ended before the stichtag" do
        member.roles.update_all(end_on: Time.zone.today - 1.day)
        expect(statistic.total_count).to eq(1)
      end

      it "does not count a role starting after the stichtag" do
        member.roles.update_all(start_on: Time.zone.today + 1.day)
        expect(statistic.total_count).to eq(1)
      end

      it "does not count a role archived before the stichtag" do
        member.roles.update_all(archived_at: 1.day.ago)
        expect(statistic.total_count).to eq(1)
      end

      it "counts a person for a past stichtag if their role was active then" do
        member.roles.update_all(start_on: 2.years.ago, end_on: 1.year.ago)
        past_stichtag = 18.months.ago.to_date.strftime("%d.%m.%Y")

        expect(statistic(date: past_stichtag).total_count).to eq(2)
        expect(statistic.total_count).to eq(1)
      end
    end

    describe "#magazine_subscribers_count" do
      it "is zero without any abo tag" do
        expect(statistic.magazine_subscribers_count).to eq(0)
      end

      it "counts a person tagged with an abo tag" do
        member.update!(tag_list: "abo:Wandern")
        expect(statistic.magazine_subscribers_count).to eq(1)
      end

      it "counts a person only once, even with multiple abo tags" do
        member.update!(tag_list: "abo:Wandern, abo:Another")
        expect(statistic.magazine_subscribers_count).to eq(1)
      end

      it "does not count non-abo tags" do
        member.update!(tag_list: "category:Foo")
        expect(statistic.magazine_subscribers_count).to eq(0)
      end

      it "is always evaluated as of today, regardless of the stichtag" do
        member.update!(tag_list: "abo:Wandern")
        member.roles.update_all(start_on: 2.years.ago, end_on: 1.year.ago)
        past_stichtag = 18.months.ago.to_date.strftime("%d.%m.%Y")

        expect(statistic(date: past_stichtag).magazine_subscribers_count).to eq(0)
      end
    end

    describe "#language_breakdown" do
      before do
        member.update!(language: "fr")
        other_member.update!(language: "de")
      end

      it "returns count and percent per language, sorted by language code" do
        expect(statistic.language_breakdown.map(&:to_h)).to eq([
          {label: "Deutsch", count: 1, percent: 50.0},
          {label: "Französisch", count: 1, percent: 50.0}
        ])
      end
    end

    describe "#gender_breakdown" do
      before do
        member.update!(gender: "w")
        other_member.update!(gender: "m")
      end

      it "returns count and percent per gender, sorted by gender code" do
        expect(statistic.gender_breakdown.map(&:to_h)).to eq([
          {label: "männlich", count: 1, percent: 50.0},
          {label: "weiblich", count: 1, percent: 50.0}
        ])
      end

      it "buckets people without a gender as unknown, sorted first" do
        other_member.update!(gender: nil)
        expect(statistic.gender_breakdown.map(&:to_h)).to eq([
          {label: "unbekannt", count: 1, percent: 50.0},
          {label: "weiblich", count: 1, percent: 50.0}
        ])
      end
    end

    describe "#age_groups" do
      it "buckets people into 10-year ranges based on the stichtag" do
        member.update!(birthday: Time.zone.today - 25.years)
        other_member.update!(birthday: Time.zone.today - 45.years)

        expect(statistic.age_groups.map(&:to_h)).to eq([
          {label: "20-29", count: 1, percent: 50.0},
          {label: "40-49", count: 1, percent: 50.0}
        ])
      end

      it "buckets people without a birthday separately, sorted last" do
        member.update!(birthday: Time.zone.today - 25.years)
        other_member.update!(birthday: nil)

        expect(statistic.age_groups.map(&:to_h)).to eq([
          {label: "20-29", count: 1, percent: 50.0},
          {label: nil, count: 1, percent: 50.0}
        ])
      end

      it "computes age relative to the stichtag, not to today" do
        member.update!(birthday: Time.zone.today - 30.years)
        other_member.update!(birthday: Time.zone.today - 45.years)

        yesterday = (Time.zone.today - 1.day).strftime("%d.%m.%Y")
        labels_at_yesterday = statistic(date: yesterday).age_groups.map(&:label)
        expect(labels_at_yesterday).to contain_exactly("20-29", "40-49")
        expect(statistic.age_groups.map(&:label)).to contain_exactly("30-39", "40-49")
      end
    end
  end
end
