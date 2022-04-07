# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

# Support for better readable migration/seed-files
class DataMigrator

  class << self

    def person_attrs_from_import_row(import_row)
      person_hash = {}
      person_hash[:alabus_id] = import_row[:id]
      person_hash[:member_number] = import_row[:membernumber]
      person_hash[:first_name] = import_row[:firstname]
      person_hash[:last_name] = import_row[:lastname]
      person_hash[:birthday] = import_row[:birthdate]
      person_hash[:email] = import_row[:email] unless Person.exists?(email: import_row[:email])
      person_hash[:address] = [import_row[:primaryaddressaddressline1],
                               import_row[:primaryaddressaddressline2]].join("\n")
      person_hash[:zip_code] = import_row[:primaryaddresszip]
      person_hash[:town] = import_row[:primaryaddresscity]

      person_hash[:language] = DataMigrator.person_language(import_row) if import_row[:language]
      person_hash[:created_at] = person_hash[:updated_at] = Time.zone.now
      person_hash
    end

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

      Role.upsert(attrs) unless Note.exists?(attrs.except(:created_at, :updated_at))
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
