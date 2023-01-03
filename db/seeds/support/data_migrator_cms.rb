# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

# Support for better readable migration/seed-files
class DataMigratorCms

  class << self

    def person_attrs_from_import_row(import_row)
      person_hash = {}
      person_hash[:sww_cms_profile_id] = import_row[:profile_id]
      person_hash[:member_number] = import_row[:membernumber]
      person_hash[:first_name] = import_row[:profile_prename]
      person_hash[:last_name] = import_row[:profile_lastname]
      person_hash[:birthday] = import_row[:birthdate]
      person_hash[:email] = import_row[:email] unless Person.exists?(email: import_row[:email])
      person_hash[:address] = [import_row[:profile_address],
                               import_row[:profile_streetnr]].join(' ')
      person_hash[:zip_code] = import_row[:profile_zip]
      person_hash[:town] = import_row[:profile_city]
      person_hash[:country] = import_row[:profile_country].presence || 'CH'

      if import_row[:profile_email].present? && Truemail.valid?(import_row[:profile_email])
        person_hash[:email] = import_row[:profile_email]
      end

      person_hash[:language] = import_row[:profile_lang] || 'de'
      person_hash[:sww_cms_legacy_password_salt] = import_row[:profile_password_salt]

      person_hash[:created_at] = person_hash[:updated_at] = Time.zone.now
      person_hash
    end

    def person_language(import_row)
      Person::LANGUAGES.invert[import_row[:language]]
    end

    def set_password!(person_hash, import_row)
      password = import_row[:profile_password]
      
      # only save bcrypt passwords
      return unless password && password.start_with?('$2y$', '$2a$')

      person_hash[:encrypted_password] = password
    end

    def assign_company!(person_hash, import_row)
      person_hash[:company_name] = import_row[:profile_firm]
      person_hash[:company] = person_hash[:company_name].present?
    end

    def default_user_group_id
      @default_user_group_id ||= Group::Benutzerkonten.find_by(parent_id: Group.root.id).id
    end

    def insert_role!(person)
      attrs = {
        person_id: person.id,
        group_id: default_user_group_id,
        type: Group::Benutzerkonten::Benutzerkonto.sti_name,
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }

      Role.upsert(attrs) unless Role.exists?(attrs.except(:created_at, :updated_at))
    end

    def insert_phone_numbers!(person, import_row)
      attrs = [
        {
          contactable_id: person.id,
          contactable_type: Person.sti_name,
          label: person.company? ? 'Arbeit' : 'Privat',
          number: import_row[:mainphone]
        },
        {
          contactable_id: person.id,
          contactable_type: Person.sti_name,
          label: 'Mobil',
          number: import_row[:mobile]
        }
      ].filter { |attr_row| attr_row[:number].present? && !PhoneNumber.exists?(attr_row) }

      PhoneNumber.upsert_all(attrs) unless attrs.empty?
    end

    def insert_social_account!(person, import_row)
      return unless import_row[:web]

      attrs = {
        contactable_id: person.id,
        contactable_type: Person.sti_name,
        label: 'Webseite',
        name: import_row[:web]
      }

      SocialAccount.upsert(attrs) unless SocialAccount.exists?(attrs)
    end

    def insert_note!(person, import_row)
      return unless import_row[:primarynote].present?

      attrs = {
        subject_id: person.id,
        author_id: person.id,
        subject_type: Person.sti_name,
        text: import_row[:primarynote],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }

      Note.upsert(attrs) unless Note.exists?(attrs.except(:created_at, :updated_at))
    end
  end
end
