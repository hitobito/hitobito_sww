# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

# Support for better readable migration/seed-files
class DataMigrator

  class << self

    def person_language(import_row)
      Person::LANGUAGES.invert[import_row[:language]]
    end

    def assign_salutation!(person_hash, import_row)
      import_salutation = import_row[:salutation]
      case import_salutation
      when 'Herr'
        person_hash[:gender] = 'm'
      when 'Frau'
        person_hash[:gender] = 'w'
      else
        person_hash[:custom_salutation] = import_salutation
      end
    end

    def assign_company!(person_hash, import_row)
      person_hash[:company] = import_row[:mmboname].eql?('Company')
      person_hash[:company_name] = import_row[:company] if person_hash[:company]
    end

    def default_contact_group_id
      @default_contact_group_id ||= Group::Kontakte.find_by(name: 'Kontakte', parent_id: Group.root.id).id
    end

    def insert_role!(person)
      attrs = {
        person_id: person.id,
        group_id: default_contact_group_id,
        type: Group::Kontakte::Kontakt.sti_name,
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }

      Role.upsert(attrs)
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
      ].filter { |attr_row| attr_row[:number].present? }

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

      SocialAccount.upsert(attrs)
    end

    def insert_note!(person, import_row)
      return unless import_row[:primarynote]

      attrs = {
        subject_id: person.id,
        author_id: person.id,
        subject_type: Person.sti_name,
        text: import_row[:primarynote],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }

      Note.upsert(attrs)
    end
  end
end
