require 'csv'
require Wagons.find('sww').root.join('db/seeds/support/data_migrator_cms.rb')
ActiveRecord::Base.logger = nil

# TODO SWW CMS PROFILE ID 42918, 49308 in CSV hat keinen Namen, löschen oder anders bereinigen
# TODO Scheinbar ist beim ersten Import eine fehlerhafte PLZ reingerutscht und bei den Callbacks geht jetzt aufgrund alles kaputt: Person.find(79555).update_column(:zip_code, nil)

@all_people_cms = CSV.parse(File.read("/tmp/all_people_cms.csv"), headers: true, col_sep: ';', header_converters: :symbol)

def row_by_cms_id(cms_profile_id)
  @all_people_cms.find { |r| r[:profile_id].to_i == cms_profile_id.to_i }
end

missing_person_creation_errors = []
taken_email_for_new_person_errors = []
invalid_zip_people = []
invalid_country_people = []
invalid_language_people = []

all_cms_profile_ids = @all_people_cms.collect{|r| r[:profile_id]}.compact
hitobito_cms_profile_id_people = Person.where(sww_cms_profile_id: all_cms_profile_ids)
non_existing_cms_profile_ids_in_hitobito = all_cms_profile_ids.map(&:to_i) - hitobito_cms_profile_id_people.pluck(:sww_cms_profile_id)

hitobito_cms_profile_id_people.find_each do |person|
  row = row_by_cms_id(person.sww_cms_profile_id)

  if person.email.nil? && row[:profile_email].present? && Truemail.valid?(row[:profile_email])
    puts "Setting mail #{row[:profile_email]} for hitobito id: #{person.id}"
    person.email = row[:profile_email]

    person.confirm
    person.skip_reconfirmation!
    person.skip_confirmation!
  end

  unless person.encrypted_password.present?
    password = DataMigratorCms.set_password!({}, row)
    if password.present?
      puts "Setting password for hitobito id: #{person.id}"
      person.encrypted_password = password
    end
  end

  unless person.valid?
    if person.errors.errors.map(&:attribute).include?(:country)
      person.country = nil
      invalid_country_people << person.id
    end
    person.validate
    if person.errors.errors.map(&:attribute).include?(:zip_code)
      person.zip_code = nil
      invalid_zip_people << person.id
    end
    if person.errors.errors.map(&:attribute).include?(:language)
      person.language = :de
      invalid_language_people << person.id
    end
  end

  if person.changed?
    person.save!
  end
end

non_existing_cms_profile_ids_in_hitobito.each do |cms_profile_id|
  row = row_by_cms_id(cms_profile_id)

  person_attrs = DataMigratorCms.person_attrs_from_import_row(row)

  if Person.exists?(email: person_attrs[:email])
    mail = person_attrs.delete(:email)
    taken_email_for_new_person_errors << "Person with cms_profile_id #{row[:profile_id]} could not set email #{mail} due to it already existing"
  end

  person_attrs[:language] = :de
  person_attrs[:country] = :CH

  person_attrs[:primary_group_id] = DataMigratorCms.default_user_group_id

  DataMigratorCms.assign_company!(person_attrs, row)

  unless Person.exists?(email: person_attrs[:email])
    DataMigratorCms.set_password!(person_attrs, row)
  end

  person_attrs.transform_values! do |v|
    if v.is_a?(String)
      v.strip!
    end
    v
  end

  puts "Creating new hitobito person for cms_profile_id: #{row[:profile_id]}"
  person = Person.new(person_attrs)
  unless person.valid?
    missing_person_creation_errors << "cms_profile_id #{row[:profile_id]}: #{person.errors.errors.map(&:attribute).join(',')}"
    next
  end
  person.confirm
  person.skip_confirmation!
  person.save!

  DataMigratorCms.insert_role!(person)
end

puts "FAILED DURING CREATION:"
puts missing_person_creation_errors.join("\n")
puts "FAILED SETTING MAIL DURING CREATION DUE TO IT ALREADY BEING TAKEN:"
puts taken_email_for_new_person_errors.join("\n")
puts "HITOBITO PERSON ID'S WITH INVALID ZIP CODE FIXED BY SETTING NIL:"
puts invalid_zip_people.join(',')
puts "HITOBITO PERSON ID'S WITH INVALID COUNTRY FIXED BY SETTING NIL:"
puts invalid_country_people.join(',')
puts "HITOBITO PERSON ID'S WITH INVALID LANGUAGE FIXED BY SETTING de:"
puts invalid_language_people.join(',')
