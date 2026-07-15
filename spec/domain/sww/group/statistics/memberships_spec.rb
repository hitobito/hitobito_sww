# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"
require_relative "date_range_filter_examples"

describe Sww::Group::Statistics::Memberships do
  let(:layer) { groups(:berner_wanderwege) }

  def statistic(params = {})
    described_class.new(layer, ActionController::Parameters.new(params))
  end

  def create_role(group:, type: Group::Mitglieder::Aktivmitglied, person: Fabricate(:person),
    start_on: 1.year.ago, end_on: nil)
    Fabricate(type.sti_name.to_sym, person: person, group: group, start_on: start_on,
      end_on: end_on)
  end

  it_behaves_like "a date range filter"

  describe "layer_only" do
    it "is disabled, so a non-layer group can be used" do
      expect(described_class.layer_only).to be false
      expect { described_class.new(groups(:berner_mitglieder)) }.not_to raise_error
    end
  end

  describe "calculations" do
    let(:mitglieder) { groups(:berner_mitglieder) }
    let(:kontakte) { groups(:berner_kontakte) }
    let(:range) { {from: "01.01.2024", to: "31.12.2024"} }

    describe "#total_entries" do
      it "counts roles starting within the range, across the whole hierarchy" do
        create_role(group: mitglieder, start_on: Date.new(2024, 6, 1))
        create_role(group: kontakte, type: Group::Kontakte::Kontakt, start_on: Date.new(2024, 7, 1))

        expect(statistic(range).total_entries).to eq(2)
      end

      it "does not count roles starting outside the range" do
        create_role(group: mitglieder, start_on: Date.new(2023, 12, 31))
        expect(statistic(range).total_entries).to eq(0)
      end
    end

    describe "#total_exits" do
      it "counts roles ending within the range" do
        create_role(group: mitglieder, start_on: Date.new(2020, 1, 1), end_on: Date.new(2024, 6, 1))
        expect(statistic(range).total_exits).to eq(1)
      end

      it "does not count roles ending outside the range" do
        create_role(group: mitglieder, start_on: Date.new(2020, 1, 1),
          end_on: Date.new(2025, 1, 15))
        expect(statistic(range).total_exits).to eq(0)
      end
    end

    describe "#net_change" do
      it "is entries minus exits" do
        create_role(group: mitglieder, start_on: Date.new(2024, 3, 1))
        create_role(group: mitglieder, start_on: Date.new(2020, 1, 1), end_on: Date.new(2024, 6, 1))

        stat = statistic(range)
        expect(stat.total_entries).to eq(1)
        expect(stat.total_exits).to eq(1)
        expect(stat.net_change).to eq(0)
      end
    end

    describe "a role type change within the same group" do
      it "counts as both an exit for the old type and an entry for the new type" do
        person = Fabricate(:person)
        create_role(group: mitglieder, type: Group::Mitglieder::Freimitglied, person: person,
          start_on: Date.new(2020, 1, 1), end_on: Date.new(2024, 6, 1))
        create_role(group: mitglieder, type: Group::Mitglieder::Aktivmitglied, person: person,
          start_on: Date.new(2024, 6, 1))

        stat = statistic(range)
        expect(stat.total_entries).to eq(1)
        expect(stat.total_exits).to eq(1)
        expect(stat.net_change).to eq(0)
      end
    end

    describe "#group_breakdowns" do
      it "lists every descendant group in the layer, even ones without any changes" do
        titles = statistic(range).group_breakdowns.map(&:title)
        expect(titles).to contain_exactly("Gremium", "Vorstand", "Geschäftsstelle", "Mitglieder",
          "Kontakte")
      end

      it "gives a group without changes an empty role_rows and a zeroed total_row" do
        breakdown = statistic(range).group_breakdowns.find { |b| b.title == "Kontakte" }
        expect(breakdown.role_rows).to be_empty
        expect(breakdown.total_row.to_h).to eq(entries: 0, exits: 0, net: 0)
      end

      it "returns entries/exits/net per role type, plus a summed total_row" do
        create_role(group: mitglieder, type: Group::Mitglieder::Aktivmitglied,
          start_on: Date.new(2024, 3, 1))
        create_role(group: mitglieder, type: Group::Mitglieder::Freimitglied,
          start_on: Date.new(2020, 1, 1), end_on: Date.new(2024, 6, 1))

        breakdown = statistic(range).group_breakdowns.find { |b| b.title == "Mitglieder" }
        expect(breakdown.role_rows.map(&:to_h)).to contain_exactly(
          {label: "Aktivmitglied", entries: 1, exits: 0, net: 1},
          {label: "Freimitglied", entries: 0, exits: 1, net: -1}
        )
        expect(breakdown.total_row.to_h).to eq(entries: 1, exits: 1, net: 0)
      end

      it "builds a breadcrumb title for a nested group, excluding the layer itself" do
        Fabricate(Group::Mitglieder.sti_name.to_sym, parent: mitglieder, name: "Aktive")

        titles = statistic(range).group_breakdowns.map(&:title)
        expect(titles).to include("Mitglieder → Aktive")
      end

      it "does not include the layer itself in the breakdown" do
        titles = statistic(range).group_breakdowns.map(&:title)
        expect(titles).not_to include(layer.to_s)
      end
    end

    describe "layer scoping" do
      let(:root) { groups(:schweizer_wanderwege) }

      it "does not descend into a different (sub-)layer's groups" do
        stat = described_class.new(root, ActionController::Parameters.new(range))
        expect(stat.group_breakdowns).to be_empty
      end

      it "does not count roles from a different (sub-)layer's groups toward the totals" do
        create_role(group: mitglieder, start_on: Date.new(2024, 3, 1))

        stat = described_class.new(root, ActionController::Parameters.new(range))
        expect(stat.total_entries).to eq(0)
        expect(stat.total_exits).to eq(0)
      end
    end

    describe "subgroup scoping" do
      it "does descend to subgroups and ignores group sibling" do
        aktive = Fabricate(Group::Mitglieder.sti_name.to_sym, parent: mitglieder, name: "Aktive")
        create_role(group: aktive, start_on: Date.new(2024, 3, 1))
        create_role(group: kontakte, type: Group::Kontakte::Kontakt, start_on: Date.new(2024, 3, 1))
        stat = described_class.new(mitglieder.reload, ActionController::Parameters.new(range))
        expect(stat.group_breakdowns.map(&:title)).to contain_exactly("Mitglieder → Aktive")
        expect(stat.total_entries).to eq(1)
      end
    end
  end
end
