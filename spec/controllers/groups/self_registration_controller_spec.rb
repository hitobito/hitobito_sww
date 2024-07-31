# frozen_string_literal: true

#  Copyright (c) 2023-2024, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Groups::SelfRegistrationController do
  let(:group) { groups(:berner_mitglieder) }

  before do
    group.update!(self_registration_role_type: Group::Mitglieder::Aktivmitglied.sti_name)
  end

  context "POST#create" do
    it "builds address using street and housenumber" do
      expect do
        post :create, params: {
          group_id: group.id,
          wizards_register_new_user_wizard: {
            new_user_form: {
              first_name: "Bob",
              gender: "m",
              last_name: "Miller",
              email: "bob.miller@example.com",
              street: "Belpstrasse",
              housenumber: "37"
            }
          }
        }
      end.to change { Person.count }.by(1)

      person = Person.find_by(email: "bob.miller@example.com")

      expect(person.address).to eq("Belpstrasse 37")
    end
  end
end
