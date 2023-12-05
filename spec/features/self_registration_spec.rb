# frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Alpen-Club. This file is part of
#  hitobito_sac_cas and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sac_cas.


require 'spec_helper'

describe :self_registration, js: true do
  Capybara.default_max_wait_time = 1.5

  let(:group) { groups(:berner_mitglieder) }

  let(:self_registration_role) { group.decorate.allowed_roles_for_self_registration.first }

  before do
    group.self_registration_role_type = self_registration_role
    group.save!

    allow(Settings.groups.self_registration).to receive(:enabled).and_return(true)
  end

  def complete_main_person_form
    fill_in 'Vorname', with: 'Max'
    fill_in 'Nachname', with: 'Muster'
    fill_in 'E-Mail', with: 'max.muster@hitobito.example.com'
    fill_in 'self_registration_main_person_attributes_street', with: 'Musterplatz'
    fill_in 'self_registration_main_person_attributes_house_number', with: '1'
    fill_in 'self_registration_main_person_attributes_zip_code', with: '8000'
    fill_in 'self_registration_main_person_attributes_town', with: 'Zürich'
    fill_in 'Geburtsdatum', with: '01.01.1980'
    country_selector = "#self_registration_main_person_attributes_country"
    find("#{country_selector}").click
    find("#{country_selector} option", text: 'Vereinigte Staaten').click
    yield if block_given?
  end

  describe 'main_person' do
    it 'validates required fields' do
      visit group_self_registration_path(group_id: group)
      click_on 'Registrieren'
      field = page.find_field("Vorname")
      expect(field.native.attribute("validationMessage")).to eq "Please fill out this field."
    end

    it 'self registers and creates new person' do
      visit group_self_registration_path(group_id: group)
      complete_main_person_form

      expect do
        click_on 'Registrieren'
      end.to change { Person.count }.by(1)
        .and change { Role.count }.by(1)
        .and change { ActionMailer::Base.deliveries.count }.by(1)

      expect(page).to have_text('Sie haben sich erfolgreich registriert. Sie erhalten in Kürze eine E-Mail mit der Anleitung, wie Sie Ihren Account freischalten können.')

      person = Person.find_by(email: 'max.muster@hitobito.example.com')
      expect(person).to be_present
      expect(person.gender).to eq 'w'
      expect(person.first_name).to eq 'Max'
      expect(person.last_name).to eq 'Muster'
      expect(person.address).to eq 'Musterplatz 1'
      expect(person.zip_code).to eq '8000'
      expect(person.town).to eq 'Zürich'
      expect(person.country).to eq 'US'
      expect(person.birthday).to eq Date.new(1980, 1, 1)
      person.confirm # confirm email

      person.password = person.password_confirmation = 'really_b4dPassw0rD'
      person.save!

      fill_in 'person_login_identity', with: 'max.muster@hitobito.example.com'
      fill_in 'person_password', with: 'really_b4dPassw0rD'

      click_button 'Anmelden'

      expect(person.roles.map(&:type)).to eq([self_registration_role.to_s])
      expect(current_path).to eq("/de#{group_person_path(group_id: group, id: person)}.html")
    end

    describe 'with privacy policy' do
      before do

        file = Rails.root.join('spec', 'fixtures', 'files', 'images', 'logo.png')
        image = ActiveStorage::Blob.create_and_upload!(io: File.open(file, 'rb'),
                                                       filename: 'logo.png',
                                                       content_type: 'image/png').signed_id
        group.layer_group.update(privacy_policy: image)
      end

      it 'sets privacy policy accepted' do
        visit group_self_registration_path(group_id: group)
        complete_main_person_form

        check 'Ich erkläre mich mit den folgenden Bestimmungen einverstanden:'
        expect do
          click_on 'Registrieren'
        end.to change { Person.count }.by(1)
        person = Person.find_by(email: 'max.muster@hitobito.example.com')
        expect(person.privacy_policy_accepted).to eq true
      end
    end
  end
end
