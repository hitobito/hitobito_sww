# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module People
  class SplitForm
    include ActiveModel::Model

    FIRST_NAME_SPLIT_PATTERNS = [
      /\s*\+\s*/i,
      /\s+und\s+/i,
      /\s+et\s+/i,
      /\s+u\.\s+/i,
      /\s+&\s+/i
    ]

    attr_reader :original_person, :person_1, :person_2, :person_2_role, :group

    validate :validate_people, :validate_person_2_role

    def initialize(group:, original_person:)
      @group = group
      @original_person = original_person
      initialize_people
    end

    def person_1_attributes=(attrs)
      original_email = person_1.email
      person_1.assign_attributes(attrs)

      return if person_1.email.present? || original_email.blank?

      person_1.additional_emails.build(
        email: original_email,
        category: ContactAccountCategory.for("AdditionalEmail", "Person").other.first
      )
    end

    def person_2_attributes=(attrs)
      person_2.assign_attributes(attrs)
      return unless person_1.email.present? && person_2.email.blank?

      person_2.additional_emails.build(
        email: person_1.email,
        category: ContactAccountCategory.for("AdditionalEmail", "Person").other.first
      )
    end

    def person_2_role_attributes=(attrs)
      role_type = find_role_type(attrs.delete(:type), Group.find_by(id: attrs[:group_id]))
      @person_2_role = role_type.new(attrs.merge(person: person_2))
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        person_1.save!
        person_2.save!
        person_2_role.save!
        person_1.household.add(person_2).save!
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    def role_group_options
      layer_ids = original_person.roles.map { _1.group.layer_group_id }.uniq
      Group.where(layer_group_id: layer_ids).without_deleted.order(:lft)
    end

    def role_group = person_2_role.group

    def proposed_first_names
      return @proposed_first_names if defined?(@proposed_first_names)

      original_first_name = original_person.first_name.to_s
      pattern = FIRST_NAME_SPLIT_PATTERNS.find { |p| original_first_name.match?(p) }

      @proposed_first_names = if pattern
        original_first_name.partition(pattern).values_at(0, 2).map(&:strip)
      else
        [original_first_name, ""]
      end
    end

    private

    def initialize_people
      @person_1 = original_person.clone.tap { _1.first_name = proposed_first_names[0] }
      @person_2 = Person.new(
        first_name: proposed_first_names[1],
        last_name: original_person.last_name
      )
      @person_2_role = Role.new(person: @person_2, group: original_person.primary_group || group)
    end

    def validate_people
      [person_1, person_2].each_with_index do |person, index|
        add_errors(index, person.errors) if person.invalid?
      end
    end

    def find_role_type(sti_name, group)
      group&.role_types&.find { _1.sti_name == sti_name } || Role
    end

    def validate_person_2_role
      person_2_role.validate
      unless role_group_options.exists?(id: person_2_role.group_id)
        person_2_role.errors.add(:group_id, :inclusion)
      end
      add_errors(1, person_2_role.errors) if person_2_role.errors.any?
    end

    def add_errors(person_index, person_errors)
      prefix = "#{Person.model_name.human} #{person_index + 1}"
      person_errors.each do |e|
        errors.add(:base, "#{prefix}: #{e.full_message}")
      end
    end
  end
end
