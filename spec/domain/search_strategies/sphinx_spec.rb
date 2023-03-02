# encoding: utf-8

#  Copyright (c) 2017, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe SearchStrategies::Sphinx, sphinx: true do
  let(:user) { people(:zuercher_wanderer) }
  let(:wanted_person) { people(:zuercher_wanderer) }

  sphinx_environment(:people) do
    describe '#list_people' do
      it 'finds by magazin_abo_number' do
        wanted_person.update!(magazin_abo_number: 123_456)
        index_sphinx

        expect(search('1234567')).not_to include wanted_person
        expect(search('12345')).to include wanted_person
      end

      it 'finds by member_number people with manual_member_number' do
        wanted_person.update!(manual_member_number: 123_456)
        index_sphinx

        expect(search(wanted_person.id.to_s)).not_to include wanted_person
        expect(search('12345')).to include wanted_person
      end

      it 'finds by member_number people without manual_member_number' do
        wanted_person.update!(manual_member_number: nil)
        index_sphinx

        expect(search(wanted_person.member_number.to_s)).to include wanted_person
      end
    end
  end

  def search(term = nil, page = nil)
    SearchStrategies::Sphinx.new(user, term, page).list_people
  end
end
