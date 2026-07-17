# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

# Shared examples for Sww::Group::Statistics::DateRangeFilter, included by every statistic
# spec that uses it (EventParticipation, Memberships). Requires the including spec to define
# a `statistic(params = {})` helper that builds a described_class instance.
shared_examples "a date range filter" do
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
end
