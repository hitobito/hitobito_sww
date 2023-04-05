require 'csv'
require Wagons.find('sww').root.join('db/seeds/support/data_migrator_cms.rb')

def update_or_create_person(row)
  person_attrs = DataMigratorCms.person_attrs_from_import_row(row)
  DataMigratorCms.assign_company!(person_attrs, row)
  DataMigratorCms.set_password!(person_attrs, row)

  if Person.exists?(sww_cms_profile_id: person_attrs[:sww_cms_profile_id])
    puts "person exists ...cms profile id: #{person_attrs[:sww_cms_profile_id]}"
    person = Person.find_by(sww_cms_profile_id: person_attrs[:sww_cms_profile_id])
    #person.update!(person_attrs)
  else
    #Person.create!(person_attrs)
    #person = Person.find_by(sww_cms_profile_id: person_attrs[:sww_cms_profile_id])
    #person.confirm
    #DataMigratorCms.insert_role!(person)
  end

end

all_people_cms = CSV.parse(File.read("/tmp/all_people_cms.csv"), headers: true, col_sep: ';', header_converters: :symbol)

# by cms profile id
all_cms_profile_ids = all_people_cms.collect{|r| r[:profile_id]}.compact

# by email
all_cms_emails = all_people_cms.collect{|r| r[:profile_email]}.compact
present_emails = Person.where(email: all_cms_emails).pluck(:email)
missing_emails = all_cms_emails - present_emails

missing_people_by_email = all_people_cms.select {|r| missing_emails.include?(r[:profile_email])}.reject{|r| !Truemail.valid?(r[:profile_email], with: :regex)}

puts missing_people_by_email.count

missing_people_by_email.each do |r|
  update_or_create_person(r)
end
