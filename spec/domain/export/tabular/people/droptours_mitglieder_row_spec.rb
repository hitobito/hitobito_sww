# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Export::Tabular::People::DroptoursMitgliederRow do
  let(:person) { people(:berner_wanderer) }
  let(:fachorganisation) { groups(:berner_wanderwege) }

  subject(:row) { described_class.new(person, fachorganisation) }

  it "#birthday returns person#birthday in dd.mm.yyyy format" do
    person.birthday = Date.new(1234, 5, 6)
    expect(row.birthday).to eq("06.05.1234")
  end

  describe "#country" do
    it "returns country code for non-CH country" do
      person.country = "DE"
      expect(row.country).to eq("DE")
    end

    it "returns nil for CH country" do
      person.country = "CH"
      expect(row.country).to be_nil
    end
  end

  it "#date_of_joining returns year of first role creation in same layer" do
    expect(person.roles).to be_present
    # person has currently valid roles, lets create an older deleted one
    person.roles.where(start_on: nil).update_all(start_on: "2016-01-01")

    first_role = Fabricate(Group::Mitglieder::Aktivmitglied.sti_name,
      group: groups(:berner_mitglieder),
      person: person,
      start_on: "2010-06-01",
      end_on: "2013-10-31")

    _other_fachorganisation_role =
      Fabricate(Group::Mitglieder::Aktivmitglied.sti_name,
        group: groups(:zuercher_mitglieder),
        person: person,
        start_on: "2003-11-01",
        end_on: "2004-12-31")

    expect(row.date_of_joining).to eq(first_role.start_on)
  end

  it "#email returns person#email" do
    expect(row.fetch(:email)).to eq(person.email)
  end

  it "#email returns additional email if person#email is blank" do
    person.email = ""
    person.additional_emails.build(email: "additional@example.com")

    expect(row.fetch(:email)).to eq("additional@example.com")
  end

  it "#fachorganisation_id returns fachorganisation#id" do
    expect(row.fetch(:fachorganisation_id)).to eq(fachorganisation.id)
  end

  it "#fachorganisation_name returns fachorganisation#name" do
    expect(row.fetch(:fachorganisation_name)).to eq(fachorganisation.name)
  end

  it "#member_number returns person#member_number" do
    expect(row.fetch(:member_number)).to eq(person.member_number)
  end

  it "#phone_number_landline returns number with label landline" do
    main = Fabricate(:phone_number, contactable: person, label: "Privat", number: "0311234567")
    expect(row.fetch(:phone_number_landline)).to eq main.number
  end

  it "#phone_number_mobile returns any number with label mobile" do
    mobile = Fabricate(:phone_number, contactable: person, label: "Mobil", number: "0781234567")
    expect(row.fetch(:phone_number_mobile)).to eq mobile.number
  end

  it "#postfach returns postbox for now" do
    person.postbox = "postbox 1234"
    expect(row.fetch(:postbox)).to eq "postbox 1234"
  end
end
