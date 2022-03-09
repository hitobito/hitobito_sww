# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require Wagons.find('sww').root.join('db/seeds/support/data_migrator.rb')

# rubocop:disable Metrics/BlockLength
namespace :import do
  desc 'Import people'
  task people: [:environment] do
    person_csv = Wagons.find('sww').root.join('db/seeds/production/people.csv')
    raise unless person_csv.exist?

    CSV.parse(person_csv.read, headers: true, header_converters: :symbol).each do |import_row|
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

      DataMigrator.assign_salutation!(person_hash, import_row)

      DataMigrator.assign_company!(person_hash, import_row)

      person_hash[:primary_group_id] = DataMigrator.default_contact_group_id
      person_hash[:created_at] = person_hash[:updated_at] = Time.zone.now

      Person.upsert(person_hash)

      person = Person.find_by(alabus_id: person_hash[:alabus_id])

      DataMigrator.insert_role!(person)
      DataMigrator.insert_phone_numbers!(person, import_row)
      DataMigrator.insert_social_account!(person, import_row)
      DataMigrator.insert_note!(person, import_row)
    end
  end
end
