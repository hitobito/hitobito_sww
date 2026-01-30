# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module People
  class SplitForm
    include ActiveModel::Model

    attr_reader :person_1, :person_2, :group

    validate :validate_people

    def initialize(attributes = {}, group:, original_person: nil)
      @group = group
      initialize_people(original_person)
      super(attributes)
    end

    def person_1_attributes=(attrs)
      @person_1.assign_attributes(attrs)
    end

    def person_2_attributes=(attrs)
      @person_2.assign_attributes(attrs)
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        @person_1.save!(validate: false)
        @person_2.save!(validate: false)
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    def layer_group = group

    private

    def initialize_people(original_person)
      @person_1 = original_person
      @person_2 = Person.new
    end

    def validate_people
      [person_1, person_2].each_with_index do |person, index|
        unless person.valid?
          person.errors.each do |error|
            errors.add(:base, "Person #{index + 1}: #{error.full_message}")
          end
        end
      end
    end
  end
end
