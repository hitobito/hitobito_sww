require "csv"

OUTPUT_DIR = Rails.root.join("tmp", "issue-366-legacy-attrs")
BASE_URL = "https://rando-community.ch/de/people"

def generate_csv_for_people(people, filename)
  headers = [
    "person_id",
    "first_name",
    "last_name",
    "company_name",
    "custom_salutation",
    "name_add_on",
    "url"
  ]

  count = 0
  CSV.open(filename, "w", write_headers: true, headers: headers) do |csv|
    people.find_each(batch_size: 1_000) do |person|
      url = "#{BASE_URL}/#{person.id}"
      csv << [
        person.id,
        person.first_name,
        person.last_name,
        person.company_name,
        person.custom_salutation,
        person.name_add_on,
        url
      ]
      count += 1
    end
  end

  count
end

timestamp = Time.zone.now.strftime("%Y%m%d-%H%M%S")
FileUtils.mkdir_p(OUTPUT_DIR)

puts "Exporting people with custom_salutation or name_add_on..."

# Base query for people with custom_salutation or name_add_on
base_scope = Person
  .where("custom_salutation != '' OR name_add_on != ''")
  .select(:id, :first_name, :last_name, :company_name, :custom_salutation, :name_add_on)

# Export all people
all_people_file = OUTPUT_DIR.join("all_people_legacy_attrs_#{timestamp}.csv")
all_count = generate_csv_for_people(base_scope, all_people_file)
puts "All people: #{all_people_file} (rows: #{all_count})"

# Export for each Fachorganisation
Group::Fachorganisation.find_each do |fachorg|
  # Get all people in roles on or below this Fachorganisation
  people_scope = base_scope
    .joins(:roles)
    .where(roles: {group_id: fachorg.self_and_descendants.pluck(:id)})
    .distinct

  next if people_scope.none?

  sanitized_name = fachorg.name.gsub(/[^0-9A-Za-z.\-]/, '_')
  fachorg_file = OUTPUT_DIR.join("fachorg_#{fachorg.id}_#{sanitized_name}_#{timestamp}.csv")
  
  fachorg_count = generate_csv_for_people(people_scope, fachorg_file)
  puts "Fachorganisation '#{fachorg.name}' (ID: #{fachorg.id}): #{fachorg_file} (rows: #{fachorg_count})"
end

puts "\nCSV export complete (#{timestamp})"
puts "Output directory: #{OUTPUT_DIR}"
