# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Person do

  describe 'member number' do
    before do
      Fabricate(:person, member_number: 100)
      Fabricate(:person, member_number: 200)
    end

    it 'sets incremented number' do
      person = Person.new(first_name: 'Klaus')

      expect(person.member_number).to be_nil

      person.save!
      person.reload

      expect(person.member_number).to eq(201)
    end

    it 'does not overwrite manually set member number' do
      person = Person.new(first_name: 'Klaus', member_number: 1)

      expect(person.member_number).to eq(1)

      person.save!

      expect(person.member_number).to eq(1)
    end

    it 'has to be unique' do
      person = Person.new(first_name: 'Klaus', member_number: 100)

      expect(person).to_not be_valid

      person.member_number = 300

      expect(person).to be_valid
    end
  end

end
