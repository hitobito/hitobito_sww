# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require Wagons.find('sww').root.join('db/seeds/support/data_migrator.rb')

# rubocop:disable Metrics/BlockLength
namespace :import do
  desc 'Import people'
  task people_sww: [:environment] do
    person_csv = Wagons.find('sww').root.join('db/seeds/production/people_sww.csv')
    raise unless person_csv.exist?

    CSV.parse(person_csv.read, headers: true, header_converters: :symbol).each do |import_row|
      person_attrs = DataMigrator.person_attrs_from_import_row(import_row)

      DataMigrator.assign_salutation!(person_attrs, import_row)

      DataMigrator.assign_company!(person_attrs, import_row)

      person_attrs[:primary_group_id] = DataMigrator.default_contact_group_id

      Person.upsert(person_attrs)

      person = Person.find_by(alabus_id: person_attrs[:alabus_id])

      DataMigrator.insert_role!(person)
      DataMigrator.insert_phone_numbers!(person, import_row)
      DataMigrator.insert_social_account!(person, import_row)
      DataMigrator.insert_note!(person, import_row)
    end
  end

  desc 'Import people for FO'
  task :people_fo, [:group_id] => :environment do |_t, args|
    person_csv = Wagons.find('sww').root.join('db/seeds/production/people_fo.csv')
    raise unless person_csv.exist?

    group = Group.find(args[:group_id])
    raise unless group

    tag_mappings = {
      'Print-Abo': { name: 'abo:print' },
      'Kombi-Abo': { name: 'abo:kombi' },
      'Einzel': { name: 'category:Einzel' },
      'Doppelmitglied': { name: 'category:Doppelmitglied' },
      'Newsletter': { name: 'Newsletter' }
    }
    tag_mappings.values.each do |tag|
      ActsAsTaggableOn::Tag.upsert(name: tag[:name])

      tag.merge!(id: ActsAsTaggableOn::Tag.find_by(name: tag[:name]).id)
    end

    CSV.parse(person_csv.read, headers: true, header_converters: :symbol).each do |import_row|
      person_attrs = DataMigrator.person_attrs_from_import_row(import_row)

      person_attrs[:magazin_abo_number] = import_row[:abo1number]
      person_attrs[:title] = import_row[:title]

      country_mappings = {
        'Schweiz': 'CH',
        'Deutschland': 'DE'
      }

      country = country_mappings[import_row[:primaryaddresscountrylictranslated]&.to_sym]
      person_attrs[:country] = country || 'CH'
      person_attrs[:name_add_on] = import_row[:nameaddon]

      taken_email = person_attrs.delete(:email) if Person.exists?(email: person_attrs[:email])

      Person.upsert(person_attrs)

      person = Person.find_by(alabus_id: person_attrs[:alabus_id])

      if taken_email.present?
        additional_mail_attrs = {
          contactable_type: Person.sti_name,
          contactable_id: person.id,
          email: taken_email,
          label: 'Privat'
        }

        AdditionalEmail.upsert(additional_mail_attrs)
      end

      mitglied_attrs = {
        person_id: person.id,
        group_id: group.id,
        type: Group::Mitglieder::Aktivmitglied.sti_name,
        created_at: import_row[:memberentrydate],
        deleted_at: import_row[:memberexitdate],
        updated_at: Time.zone.now
      }

      magazin_abo_attrs = {
        person_id: person.id,
        group_id: group.id,
        type: Group::Mitglieder::MagazinAbonnent.sti_name,
        created_at: import_row[:abo1start],
        deleted_at: import_row[:abo1end],
        updated_at: Time.zone.now
      }

      [mitglied_attrs, magazin_abo_attrs].each do |attrs|
        if attrs[:deleted_at].present? && attrs[:created_at].nil?
          attrs[:created_at] = DateTime.parse(attrs[:deleted_at]).yesterday
        end

      # Upsert doesn't set deleted_at for some reason
      # Role.new(attrs).save(validate: false)
        Role.create!(attrs)

      end

      tagging_attrs = { taggable_id: person.id, taggable_type: Person.sti_name }

      [:abo1, :primarycategory, :primarycommchannel].each do |tag|
        tag_id = tag_mappings[import_row[tag]&.to_sym].try(:[], :id)

        next unless tag_id

        attrs = tagging_attrs.merge({ tag_id: tag_id })

        ActsAsTaggableOn::Tagging.upsert(attrs)

      end

      DataMigrator.insert_phone_numbers!(person, import_row)
      DataMigrator.insert_social_account!(person, import_row)
      DataMigrator.insert_note!(person, import_row)
    end
  end
end
