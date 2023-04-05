require 'csv'

def valid_pw_hashes?(row)
  salt = row[:profile_password_salt]
  hash = row[:profile_password]
      
  hash.present? && hash.start_with?('$2y$', '$2a$') && salt.present?
end

all_people_cms = CSV.parse(File.read("/tmp/all_people_cms.csv"), headers: true, col_sep: ';', header_converters: :symbol)
puts "Number of entries in total: #{all_people_cms.count}"

# exist in hitobito by cms_profile_id
all_cms_profile_ids = all_people_cms.collect{|r| r[:profile_id]}.compact
hitobito_cms_profile_id_people = Person.where(sww_cms_profile_id: all_cms_profile_ids)
puts "Number of entries exist in hitobito by cms_profile_id: #{hitobito_cms_profile_id_people.count}"

# valid e-mail addresses
valid_email_entries = all_people_cms.select{|r| Truemail.valid?("#{r[:profile_email]}", with: :regex)}
puts "Number of entries with valid E-Mails: #{valid_email_entries.count}"

# valid e-mail addresses and valid password hashes
valid_email_and_pw_hash_entries = valid_email_entries.select{|r| valid_pw_hashes?(r)}
puts "Number of entries with valid E-Mail and Valid Password Hash: #{valid_email_and_pw_hash_entries.count}"
