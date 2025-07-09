# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require 'spec_helper'

describe Export::Tabular::People::PersonRow do

  let(:person) { people(:berner_wanderer) }
  let(:row) { described_class.new(person) }

  subject { row }

  describe 'sww salutation' do
    context 'with gender other' do
      before { person.update(gender: nil) }

      it { expect(row.fetch(:sww_salutation)).to eq 'Andere' }
    end

    context 'with gender f' do
      before { person.update(gender: 'w') }
      it { expect(row.fetch(:sww_salutation)).to eq 'Frau' }
    end

    context 'with gender m' do
      before { person.update(gender: 'm') }
      it { expect(row.fetch(:sww_salutation)).to eq 'Herr' }
    end
  end

  describe 'roles' do
    subject(:roles) { row.fetch(:roles) }
    before { person.roles.first.update(start_on: Time.zone.local(2024, 10, 29, 13, 37)) }

    context 'with no end date' do
      it 'includes start' do
        is_expected.to eq("Aktivmitglied Berner Wanderwege BWW / Mitglieder (29.10.2024-)")
      end
    end

    context 'with end date' do
      before { person.roles.first.update(end_on:  Time.zone.local(Date.current.year, 12, 31, 10)) }
      it 'includes start' do
        is_expected.to eq("Aktivmitglied Berner Wanderwege BWW / Mitglieder (29.10.2024-31.12.#{Date.current.year})")
      end
    end

    context 'with multiple roles' do
      before do
        Fabricate(Group::Mitglieder::Aktivmitglied.name.to_sym, person: person,
                  group: groups(:zuercher_mitglieder), start_on: Time.zone.local(1970, 1, 1, 4))
      end
      it 'includes all roles' do
        is_expected.to eq(["Aktivmitglied Berner Wanderwege BWW / Mitglieder (29.10.2024-)",
                           "Aktivmitglied Zürcher Wanderwege / Mitglieder (01.01.1970-)"].join(", "))
      end
    end
  end
end
