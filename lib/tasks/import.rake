# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require Wagons.find('sww').root.join('db/seeds/support/data_migrator.rb')
require Wagons.find('sww').root.join('db/seeds/support/data_migrator_cms.rb')

# rubocop:disable Metrics/BlockLength, Metrics/LineLength
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
      'Newsletter': { name: 'Newsletter' }
    }
    tag_mappings.values.each do |tag|
      ActsAsTaggableOn::Tag.upsert(name: tag[:name])

      tag.merge!(id: ActsAsTaggableOn::Tag.find_by(name: tag[:name]).id)
    end

    ActiveRecord::Base.transaction do
      failed_import_rows = []

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
        person_attrs[:primary_group_id] = group.id

        DataMigrator.assign_salutation!(person_attrs, import_row)

        DataMigrator.assign_company!(person_attrs, import_row)

        if person_attrs[:alabus_id]
          Person.upsert(person_attrs)
        else
          failed_import_rows << import_row
          next
        end

        person = Person.find_by(alabus_id: person_attrs[:alabus_id])

        unless person
          failed_import_rows << import_row
          next
        end

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

          next unless attrs[:created_at]

          # Because of a known issue of the acts_as_paranoid gem,
          # you can not directly create a model in a deleted state.
          # Thus we have to update it afterwards.
          Role.insert(attrs)
          Role.with_deleted.last.update(attrs)
        end

        tagging_attrs = { taggable_id: person.id, taggable_type: Person.sti_name, context: 'tags' }

        if import_row[:primarycategory].present?
          tag_name = "category:#{import_row[:primarycategory]}"
          tag = ActsAsTaggableOn::Tag.find_or_create_by!(name: tag_name)

          ActsAsTaggableOn::Tagging.upsert(tagging_attrs.merge(tag_id: tag.id))
        end

        [:abo1, :primarycommchannel].each do |tag|
          tag_id = tag_mappings[import_row[tag]&.to_sym].try(:[], :id)

          next unless tag_id

          attrs = tagging_attrs.merge({ tag_id: tag_id })

          ActsAsTaggableOn::Tagging.upsert(attrs)
        end

        DataMigrator.insert_phone_numbers!(person, import_row)
        DataMigrator.insert_social_account!(person, import_row)
        DataMigrator.insert_note!(person, import_row)

      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
        failed_import_rows << import_row
      end

      total_count = CSV.parse(person_csv.read, headers: true).size
      successful_count = total_count - failed_import_rows.size
      puts "Successfully imported #{successful_count}/#{total_count} rows"
      if failed_import_rows.any?
        puts "FAILED ROWS:"
        puts failed_import_rows.map { |row| ["first_name: #{row[:firstname]}",
                                             "last_name: #{row[:lastname]}",
                                             "email: #{row[:email]}",
                                             "alabus_id: #{row[:id]}"].join(', ') }.join("\n")
        puts "\nnothing was imported due to errors. Please fix import source file and try again."
        raise ActiveRecord::Rollback
      end

    end
  end

  desc 'Import invoices for FO'
  task :invoices_fo, [:layer_id] => :environment do |_t, args|
    invoice_csv = Wagons.find('sww').root.join('db/seeds/production/invoices_fo.csv')

    raise "#{invoice_csv} must be present" unless invoice_csv.exist?

    raise 'group id must be passed as first argument' unless args[:layer_id]

    layer = Group.find(args[:layer_id])
    raise unless layer

    ActiveRecord::Base.transaction do

      failed_import_rows = []
      non_open_import_rows = []

      CSV.parse(invoice_csv.read, headers: true, header_converters: :symbol).each do |import_row|
        unless import_row[:status] == 'Offen'
          non_open_import_rows << import_row.to_h
          next
        end

        unless import_row[:id].present?
          failed_import_rows << import_row.to_h.merge(failing_note: :'id not present')
          next
        end

        person = Person.find_by(alabus_id: import_row[:id])

        unless person.present?
          failed_import_rows << import_row.to_h.merge(failing_note: :'person not found')
          next
        end

        invoice_attrs = {}

        invoice_attrs[:title] = ['Rechnung Alabus', import_row[:primarycategory]].compact.join(' ')
        invoice_attrs[:state] = :issued
        invoice_attrs[:esr_number] = import_row[:esr]
        invoice_attrs[:sent_at] = DateTime.parse(import_row[:billdate]) if import_row[:billdate]
        invoice_attrs[:created_at] = DateTime.parse(import_row[:createdon]) if import_row[:createdon]

        invoice_attrs[:recipient_id] = person.id

        invoice_attrs[:invoice_items_attributes] = [
          { name: import_row[:primarycategory], unit_cost: import_row[:amount] || 0, count: 1 }
        ]

        invoice_attrs[:group_id] = layer.id

        # The Invoice model has a couple of callbacks that we need to fill required attributes.
        # However it also overwrites a couple of our attributes thus we have to update afterwards
        invoice = Invoice.create!(invoice_attrs)
        invoice.update!(invoice_attrs.except(:invoice_items_attributes))

        invoice.reload

        unless invoice.present?
          failed_import_rows << import_row.to_h.merge(failing_note: :'invoice not found after reload')
        end

      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid, Mysql2::Error => e
        failed_import_rows << import_row.to_h.merge(failing_note: e.message)
      end

      total_count = CSV.parse(invoice_csv.read, headers: true).size - non_open_import_rows.size
      successful_count = total_count - failed_import_rows.size
      puts "Successfully imported #{successful_count}/#{total_count} rows"
      if non_open_import_rows.any?
        puts 'ROWS WITH STATUS OTHER THAN "Offen":'
        puts non_open_import_rows.map { |row|
          ["esr_number: #{row[:esr]}",
           "sent_at: #{row[:billdate]}",
           "created_at: #{row[:createdon]}",
           "alabus_id: #{row[:id]}",
           "amount: #{row[:amount]}"].join(', ')
        }.join("\n")
      end

      if failed_import_rows.any?
        puts "FAILED ROWS:"
        puts failed_import_rows.map { |row|
          ["esr_number: #{row[:esr]}",
           "sent_at: #{row[:billdate]}",
           "created_at: #{row[:createdon]}",
           "alabus_id: #{row[:id]}",
           "amount: #{row[:amount]}",
           "failing_note: #{row[:failing_note].to_s}"].join(', ')
        }.join("\n")

        puts "\nnothing was imported due to errors. Please fix import source file and try again."
        raise ActiveRecord::Rollback
      end
    end
  end

  desc 'Imports people from CMS'
  task people_cms: [:environment] do
    person_csv = Wagons.find('sww').root.join('db/seeds/production/people_cms.csv')
    raise unless person_csv.exist?

    duplicate_profile_ids = Person.group(:sww_cms_profile_id).count.select { |_k, v| v > 1 }.keys

    if duplicate_profile_ids.any?
      raise ['Duplicate sww_cms_profile_id found in database:',
             duplicate_profile_ids].flatten.join("\n")
    end

    ActiveRecord::Base.transaction do
      failed_import_rows = []

      CSV.parse(person_csv.read, headers: true, header_converters: :symbol, col_sep: ';').each do |import_row|
        person_attrs = DataMigratorCms.person_attrs_from_import_row(import_row)

        person_attrs[:primary_group_id] = DataMigratorCms.default_user_group_id

        DataMigratorCms.assign_company!(person_attrs, import_row)

        unless Person.exists?(email: person_attrs[:email])
          DataMigratorCms.set_password!(person_attrs, import_row)
        end

        Person.upsert(person_attrs)

        person = Person.find_by(sww_cms_profile_id: person_attrs[:sww_cms_profile_id])

        DataMigratorCms.insert_role!(person)

      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
        failed_import_rows << import_row
      end

      total_count = CSV.parse(person_csv.read, headers: true).size
      successful_count = total_count - failed_import_rows.size
      puts "Successfully imported #{successful_count}/#{total_count} rows"
      if failed_import_rows.any?
        puts "FAILED ROWS:"
        puts failed_import_rows.map { |row| ["first_name: #{row[:profile_prename]}",
                                             "last_name: #{row[:profile_lastname]}",
                                             "email: #{row[:profile_email]}",
                                             "cms_profile_id: #{row[:profile_id]}"].join(', ') }.join("\n")
        puts "\nnothing was imported due to errors. Please fix import source file and try again."
        raise ActiveRecord::Rollback
      end
    end
  end
end
