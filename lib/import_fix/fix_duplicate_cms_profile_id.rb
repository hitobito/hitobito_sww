def duplicate_entries
  columns_that_make_record_distinct = [:sww_cms_profile_id]
  distinct_ids = Person.select("MIN(id) as id").group(columns_that_make_record_distinct).map(&:id)
  Person.where.not(sww_cms_profile_id: nil).where.not(id: distinct_ids)
end

def compare_person_entries(cms_profile_id)
  duplicates = Person.where(sww_cms_profile_id: cms_profile_id)
end

@duplicate_entries = duplicate_entries

puts "There are #{@duplicate_entries.count} Person entries with duplicate sww_cms_profile_id"

duplicate_profile_ids = @duplicate_entries.collect{|p| p.sww_cms_profile_id}.uniq
duplicate_profile_ids.each do |id|
  compare_person_entries(id)
end
