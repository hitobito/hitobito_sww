# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Export::Tabular::People::DroptoursMitglieder do
  let(:fachorganisation) { groups(:berner_wanderwege) }
  let(:mitglieder_group) { groups(:berner_mitglieder) }
  let(:mitglied) { people(:berner_wanderer) }

  subject(:tabular) { described_class.new(fachorganisation) }

  its(:model_class) { is_expected.to eq Person }
  its(:row_class) { is_expected.to eq Export::Tabular::People::DroptoursMitgliederRow }

  it "#attributes" do
    expect(tabular.attributes).to eq(
      [
        :id,
        :member_number,
        :last_name,
        :first_name,
        :address_care_of,
        :address,
        :postbox,
        :zip_code,
        :town,
        :country,
        :birthday,
        :phone_number_landline,
        :phone_number_mobile,
        :email,
        :gender,
        :language,
        :date_of_joining,
        :additional_information
      ]
    )
  end

  describe "#export_groups" do
    it "includes only Mitglieder groups having #droptours_export=true" do
      excluded1 = Fabricate(Group::Mitglieder.sti_name, parent: fachorganisation)
      included = Fabricate.times(2, Group::Mitglieder.sti_name, parent: fachorganisation,
        droptours_export: true)
      excluded2 = Fabricate(Group::Mitglieder.sti_name, parent: fachorganisation,
        droptours_export: false)

      expect(tabular.export_groups).to include(*included)
      expect(tabular.export_groups).not_to include(excluded1, excluded2)
    end
  end

  describe "#mitglieder" do
    it "includes people having a role in a droptours_export=true Mitglieder group" do
      mitglieder_group.update!(droptours_export: true)
      expect(tabular.mitglieder).to include(mitglied)
    end

    it "excludes people not having a role in a droptours_export=true Mitglieder group" do
      mitglieder_group.update!(droptours_export: false)
      expect(tabular.mitglieder).not_to include(mitglied)
    end
  end
end
