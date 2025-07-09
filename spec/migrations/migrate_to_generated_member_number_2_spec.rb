# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require 'spec_helper'
require_relative '../../db/migrate/20230119132734_migrate_to_generated_member_number_2.rb'

describe MigrateToGeneratedMemberNumber2 do
  let(:migration) { described_class.new.tap { |m| m.verbose = false } }

  let(:calculation_offset) { Sww::Person::MEMBER_NUMBER_CALCULATION_OFFSET }
  let(:some_role_type) { :"Group::Geschaeftsstelle::Mitarbeiter" }

  def build_person(manual_member_number, role_deleted_at: nil)
    Fabricate.build(:person, manual_member_number: manual_member_number, roles: [
      Fabricate.build(some_role_type, group: Group.first, created_at: Time.now, deleted_at: role_deleted_at)
    ]).tap {|person| person.save(validate: false) }
  end

  xit '#up works correctly' do
    migration.instance_exec do
      remove_index :people, :manual_member_number, unique: true, if_exists: true
    end

    # prepare test data
    # * a person without any roles
    # * a person with a deleted role ('expired')
    # * a person with a role deleted in the future ('expiring')
    # * a person with manual_member_number < calculation offset, without 'active' roles
    # * a person with manual_member_number < calculation offset
    # * a person with manual_member_number >= calculation offset
    # * two people with the same manual_member_number >= calculation offset
    # * two people with the same manual_member_number < calculation offset

    person_without_roles = Fabricate(:person, manual_member_number: 123456)
    person_with_expired_role = build_person(123457, role_deleted_at: Time.zone.now)
    person_with_expiring_role = build_person(123458, role_deleted_at: 1.minute.from_now)

    unique_low_member_number = calculation_offset - 1
    person_with_low_member_number = build_person(unique_low_member_number)

    unique_high_member_number = calculation_offset
    person_with_high_member_number = build_person(unique_high_member_number)

    duplicate_high_member_number = 424242
    duplicate_people_high_member_number = [
      build_person(duplicate_high_member_number),
      build_person(duplicate_high_member_number)
    ]

    duplicate_low_member_number = 42
    duplicate_people_low_member_number = [
      build_person(duplicate_low_member_number),
      build_person(duplicate_low_member_number)
    ]
    first_duplicate, second_duplicate = *duplicate_people_low_member_number.sort_by(&:id)

    migration.up
    Person.reset_column_information

    # Person without 'active' role should not have manual_member_number
    expect(person_without_roles.reload.manual_member_number).to eq nil
    expect(person_with_expired_role.reload.manual_member_number).to eq nil

    # Person with role expiring in the future should have manual_member_number
    expect(person_with_expiring_role.reload.manual_member_number).to eq 123458

    # People with id >= offset should not have manual_member_number
    expect(person_with_high_member_number.reload.manual_member_number).to eq nil
    expect(duplicate_people_high_member_number.map {|p| p.reload.manual_member_number }).to eq [nil,nil]

    # Person with unique low member number < offset should have manual_member_number
    expect(person_with_low_member_number.reload.manual_member_number).to eq unique_low_member_number

    # For people with duplicate but low member numbers, only the first person should have manual_member_number
    expect(first_duplicate.reload.manual_member_number).to eq duplicate_low_member_number
    expect(second_duplicate.reload.manual_member_number).to eq nil
  end
end
