# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe "people split", js: true do
  let(:mitglieder) { groups(:berner_mitglieder) }
  let(:gremium) { groups(:berner_gremium) }

  let(:user) do
    person = Fabricate(Group::Geschaeftsstelle::Mitarbeiter.sti_name,
      group: groups(:berner_geschaeftsstelle)).person
    person.update!(email: "admin@example.com")
    person
  end

  let(:person) do
    Person.create!(
      first_name: "Tom + Tina",
      last_name: "Tester",
      email: "tom.tina@example.com",
      primary_group: mitglieder
    ).tap do |p|
      Fabricate(Group::Mitglieder::Aktivmitglied.sti_name, person: p, group: mitglieder)
    end
  end

  let(:split_path) do
    new_group_person_split_path(group_id: mitglieder.id, person_id: person.id)
  end

  before do
    sign_in(user)
  end

  it "displays validation errors when form is submitted with invalid data" do
    visit split_path

    # Try to split without selecting a role type for person 2, which is required
    click_on "Aufteilen"

    # Should stay on the split path and show an error message
    expect(page).to have_current_path(split_path)
    expect(page).to have_selector(".alert-danger", text: "Person 2: Rolle muss ausgefüllt werden")
  end

  it "successfully splits the person and redirects with a flash message" do
    visit split_path

    # first names should be pre-filled from split pattern "Tom + Tina"
    expect(page).to have_field("people_split_form_person_1_attributes_first_name", with: "Tom")
    expect(page).to have_field("people_split_form_person_2_attributes_first_name", with: "Tina")

    # select a role type for person 2
    select "Aktivmitglied", from: "people_split_form_person_2_role_attributes_type"

    expect do
      click_on "Aufteilen"
      expect(page).to have_text("Person wurde erfolgreich aufgeteilt.")
    end.to change { Person.count }.by(1)

    # Should redirect to the original persons profile page and show a success message
    expect(page).to have_current_path(group_person_path(mitglieder.id, person))
    expect(page).to have_selector(".alert-success", text: "Person wurde erfolgreich aufgeteilt.")
  end

  it "updates role types when selecting a different group" do
    visit split_path

    # initial role type options should include Mitglieder roles
    expect(page).to have_select("people_split_form_person_2_role_attributes_type",
      with_options: ["Aktivmitglied"])

    # change group to Gremium, triggers AJAX role_types call
    select gremium.to_s, from: "people_split_form_person_2_role_attributes_group_id"

    # role type options should update to Gremium roles
    expect(page).to have_select("people_split_form_person_2_role_attributes_type",
      with_options: ["Leitung", "Mitglied"])
    expect(page).to have_no_select("people_split_form_person_2_role_attributes_type",
      with_options: ["Aktivmitglied"])

    # change group back to Mitglieder, triggers AJAX role_types call
    select mitglieder.to_s, from: "people_split_form_person_2_role_attributes_group_id"

    expect(page).to have_select("people_split_form_person_2_role_attributes_type",
      with_options: ["Aktivmitglied"])

    expect(page).to have_no_select("people_split_form_person_2_role_attributes_type",
      with_options: ["Leitung"])
  end
end
