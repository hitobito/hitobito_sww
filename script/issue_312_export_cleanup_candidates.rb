require "csv"
require "set"

ROLE_TYPE = "Group::Benutzerkonten::Benutzerkonto"
OUTPUT_DIR = Rails.root.join("tmp", "issue-312-cleanup-check")

def extract_role_types(version)
  role_types = []

  begin
    changeset = version.changeset
    if changeset.is_a?(Hash)
      type_change = changeset["type"] || changeset[:type]
      role_types.concat(Array(type_change).compact)
    end
  rescue StandardError
  end

  [version.object, version.object_changes].compact.each do |payload|
    role_types.concat(payload.to_s.scan(/Group::[A-Za-z0-9_:]+/))
  end

  role_types.compact.map(&:to_s).uniq
end

puts "Building role history index from current roles and PaperTrail versions..."

people_with_any_role_footprint = Set.new
people_with_non_benutzerkonto_role = Set.new

Role.with_inactive.select(:id, :person_id, :type).find_in_batches(batch_size: 5_000) do |roles|
  roles.each do |role|
    next if role.person_id.nil?

    people_with_any_role_footprint << role.person_id
    people_with_non_benutzerkonto_role << role.person_id if role.type != ROLE_TYPE
  end
end

PaperTrail::Version
  .where(item_type: Role.sti_name, main_type: Person.sti_name)
  .where.not(main_id: nil)
  .select(:id, :main_id, :object, :object_changes)
  .find_in_batches(batch_size: 5_000) do |versions|
    versions.each do |version|
      person_id = version.main_id
      next if person_id.nil?

      people_with_any_role_footprint << person_id

      role_types = extract_role_types(version)
      if role_types.any? { |type| type.present? && type != ROLE_TYPE }
        people_with_non_benutzerkonto_role << person_id
      end
    end
  end

def role_status_for(person_id, people_with_any_role_footprint, people_with_non_benutzerkonto_role)
  if people_with_non_benutzerkonto_role.include?(person_id)
    "has_non_benutzerkonto_roles"
  elsif people_with_any_role_footprint.include?(person_id)
    "only_benutzerkonto_roles"
  else
    "never_had_role"
  end
end

def role_condition_met?(person_id, people_with_non_benutzerkonto_role)
  !people_with_non_benutzerkonto_role.include?(person_id)
end

def blank_email?(email)
  email.to_s.strip.empty?
end

timestamp = Time.zone.now.strftime("%Y%m%d-%H%M%S")
FileUtils.mkdir_p(OUTPUT_DIR)

file_1 = OUTPUT_DIR.join("issue-312-file-1-never-logged-in.csv")
file_2 = OUTPUT_DIR.join("issue-312-file-2-never-logged-in-or-no-email.csv")

headers = [
  "person_id",
  "first_name",
  "last_name",
  "email",
  "sign_in_count",
  "last_sign_in_at",
  "created_at",
  "updated_at",
  "role_status"
]

count_1 = 0
count_2 = 0
created_before = 2.years.ago

CSV.open(file_1, "w", write_headers: true, headers: headers) do |csv_1|
  CSV.open(file_2, "w", write_headers: true, headers: headers) do |csv_2|
    Person.select(:id, :first_name, :last_name, :email, :sign_in_count, :last_sign_in_at, :created_at, :updated_at)
      .where("created_at < ?", created_before)
      .find_in_batches(batch_size: 5_000) do |people|
        people.each do |person|
          next unless role_condition_met?(person.id, people_with_non_benutzerkonto_role)

          never_logged_in = person.sign_in_count.to_i.zero?
          no_email = blank_email?(person.email)
          role_status = role_status_for(
            person.id,
            people_with_any_role_footprint,
            people_with_non_benutzerkonto_role
          )

          row = [
            person.id,
            person.first_name,
            person.last_name,
            person.email,
            person.sign_in_count,
            person.last_sign_in_at,
            person.created_at,
            person.updated_at,
            role_status
          ]

          if never_logged_in
            csv_1 << row
            count_1 += 1
          end

          if never_logged_in || no_email
            csv_2 << row
            count_2 += 1
          end
        end
      end
  end
end

puts "CSV export complete (#{timestamp})"
puts "Only includes people created before: #{created_before}"
puts "File 1: #{file_1} (rows: #{count_1})"
puts "File 2: #{file_2} (rows: #{count_2})"