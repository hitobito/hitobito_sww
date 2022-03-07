# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Person do

  it 'includes custom attributes' do
    %I[custom_salutation magazin_abo_number].each do |a|
      expect(Person::PUBLIC_ATTRS).to include(a)
    end

    %I[member_number alabus_id].each do |a|
      expect(Person::INTERNAL_ATTRS).to include(a)
    end
  end

  describe 'member number' do
    before do
      Person.destroy_all
      Fabricate(:person)
      Fabricate(:person)
    end

    it 'sets incremented number' do
      person = Person.new(first_name: 'Klaus')

      expect(person.member_number).to be_nil

      person.save!
      person.reload

      expect(person.member_number).to eq(100_002)
    end

    it 'does not overwrite manually set member number' do
      person = Person.new(first_name: 'Klaus', member_number: 1)

      expect(person.member_number).to eq(1)

      person.save!

      expect(person.member_number).to eq(1)
    end

    it 'has to be unique if bigger than init value for new records' do
      person = Person.new(first_name: 'Klaus', member_number: 100_000)

      expect(person).to_not be_valid

      person.member_number = 100_002

      expect(person).to be_valid
    end
  end

end
