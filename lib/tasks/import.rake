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

    raise 'group id must be passed as first argument' unless args[:group_id]

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

      DataMigrator.assign_salutation!(person_attrs, import_row)

      DataMigrator.assign_company!(person_attrs, import_row)

      Person.upsert(person_attrs)

      person = Person.find_by(alabus_id: person_attrs[:alabus_id])

      if import_row[:email].present? && person_attrs[:email].nil? # email is already taken
        additional_mail_attrs = {
          contactable_type: Person.sti_name,
          contactable_id: person.id,
          email: import_row[:email],
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
        attrs[:created_at] = DateTime.parse(attrs[:created_at]) if attrs[:created_at]
        attrs[:deleted_at] = DateTime.parse(attrs[:deleted_at]) if attrs[:deleted_at]

        if attrs[:deleted_at].present? && attrs[:created_at].nil?
          attrs[:created_at] = attrs[:deleted_at].yesterday
        end

        # Because of a known issue of the acts_as_paranoid gem,
        # you can not directly create a model in a deleted state.
        # Thus we have to update it afterwards.
        Role.insert(attrs)
        Role.last.update(attrs)
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

  desc 'Import invoices for FO'
  task :invoices_fo, [:layer_id] => :environment do |_t, args|
    invoice_csv = Wagons.find('sww').root.join('db/seeds/production/invoices_fo.csv')
    raise unless invoice_csv.exist?

    layer = Group.find(args[:layer_id])
    raise unless layer

    CSV.parse(invoice_csv.read, headers: true, header_converters: :symbol).each do |import_row|
      next unless import_row[:status] == 'Offen'

      person = Person.find_by(alabus_id: import_row[:id])

      invoice_attrs = {}

      invoice_attrs[:title] = ['Rechnung Alabus', import_row[:kategorien]].compact.join(' ')
      invoice_attrs[:state] = :issued
      invoice_attrs[:esr_number] = import_row[:referenznummer]
      invoice_attrs[:sent_at] = import_row[:rechnungsdatum]
      invoice_attrs[:created_at] = import_row[:erstellt_am]

      if person.present?
        invoice_attrs[:recipient_id] = person.id
      else
        invoice_attrs[:recipient_email] = import_row[:email]
        invoice_attrs[:recipient_address] = [import_row[:strassenr],
                                             import_row[:plz],
                                             import_row[:ort]].join(' ')
      end

      invoice_attrs[:invoice_items_attributes] = [
        { name: import_row[:kategorien], unit_cost: import_row[:rechnungsbetrag] || 0, count: 1 }
      ]

      invoice_attrs[:group_id] = layer.id

      Invoice.create!(invoice_attrs)
    end
  end
end
