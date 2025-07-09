# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require "spec_helper"

describe Export::Tabular::People::ParticipationsListRow do
  let(:participation) { event_participations(:top_participant) }
  let(:person) { participation.person }
  let(:row) { described_class.new(participation) }

  it "contains mobile phone number" do
    person.phone_numbers.create! label: "Mobil", number: "079 123 45 67"

    expect(row.phone_mobile).to eq "+41 79 123 45 67"
  end

  describe "full address" do
    it "contains all values" do
      expect(row.full_address).to eq "Belpstrasse 37, 3007 Bern"
    end

    it "works with missing values" do
      person.update! zip_code: nil

      expect(row.full_address).to eq "Belpstrasse 37, Bern"
    end
  end
end
