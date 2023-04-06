@duplicates_with_no_email_person_ids = []

def duplicate_entries
  columns_that_make_record_distinct = [:sww_cms_profile_id]
  distinct_ids = Person.select("MIN(id) as id").group(columns_that_make_record_distinct).map(&:id)
  Person.where.not(sww_cms_profile_id: nil).where.not(id: distinct_ids)
end

def compare_person_entries(cms_profile_id)
  duplicates = Person.where(sww_cms_profile_id: cms_profile_id)

  # check if one email present
  unless duplicates.one?{|p| p.email.present?}
    @duplicates_with_no_email_person_ids.push(duplicates.collect(&:id).join(','))
    return
  end

  duplicates.each do |p|
    if p.email.nil?
      p.destroy!
    end
  end
end

@duplicate_entries = duplicate_entries

puts "There are #{@duplicate_entries.count} Person entries with duplicate sww_cms_profile_id"

duplicate_profile_ids = @duplicate_entries.collect{|p| p.sww_cms_profile_id}.uniq
duplicate_profile_ids.each do |id|
  compare_person_entries(id)
end

puts "The following duplicates do not have an email: #{@duplicates_with_no_email_person_ids}"
