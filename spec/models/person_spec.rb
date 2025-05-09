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

    %I[member_number manual_member_number alabus_id].each do |a|
      expect(Person::INTERNAL_ATTRS).to include(a)
    end
  end

  it '::MEMBER_NUMBER_CALCULATION_OFFSET is correct' do
    expect(described_class::MEMBER_NUMBER_CALCULATION_OFFSET).to eq 300_000
  end

  describe '#manual_member_number' do
    it 'should validate uniqueness' do
      _person = Fabricate(:person, manual_member_number: 42)
      duplicate = Fabricate.build(:person, manual_member_number: 42)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:manual_member_number]).to include("ist bereits vergeben")
    end

    it 'should validate value' do
      person = Fabricate.build(:person, manual_member_number: described_class::MEMBER_NUMBER_CALCULATION_OFFSET)
      expect(person).not_to be_valid

      person.manual_member_number -= 1
      expect(person).to be_valid

      person.manual_member_number = nil
      expect(person).to be_valid
    end

    it 'can be blank' do
      person = Fabricate.build(:person, manual_member_number: nil)
      person.validate
      expect(person.errors[:manual_member_number]).to be_empty
    end
  end

  describe '#member_number' do
    it 'returns number calculated from #id and offset' do
      person = Fabricate(:person)
      expect(person.member_number).to eq person.id + described_class::MEMBER_NUMBER_CALCULATION_OFFSET
    end

    it 'returns nil for unpersisted instance' do
      person = Fabricate.build(:person)
      expect(person).not_to be_persisted
      expect(person.member_number).to eq nil
    end

    it 'returns #manual_member_number if present' do
      manual_member_number = 42
      person = Fabricate.build(:person, manual_member_number: manual_member_number)
      expect(person.member_number).to eq manual_member_number
    end
  end

  describe '#finance_groups' do
    it 'returns all layers if complete_finance permission is given' do
      all_layers = groups.select(&:layer)

      person = Fabricate(Group::SchweizerWanderwege::Support.sti_name.to_sym,
                         group: groups(:schweizer_wanderwege)).person

      expect(person.finance_groups).to match_array(all_layers)
    end

    it 'returns layers of which finance permission is given' do
      person = Fabricate(Group::Geschaeftsstelle::Kassier.sti_name.to_sym,
                         group: groups(:berner_geschaeftsstelle)).person

      expect(person.finance_groups).to eq([groups(:berner_wanderwege)])
    end

    it 'returns no layers when no finance permission is given' do
      person = Fabricate(Group::Geschaeftsstelle::Mitarbeiter.sti_name.to_sym,
                         group: groups(:berner_geschaeftsstelle)).person

      expect(person.finance_groups).to be_empty
    end
  end

  describe '#sww_salutation' do
    let(:person) { people(:berner_wanderer) }

    context 'with person language de' do
      before { person.update(language: :de) }

      context 'with gender other' do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq 'Andere' }
        it { expect(person.sww_salutation(skip_other: true)).to be_nil }
      end

      context 'with gender f' do
        before { person.update(gender: 'w') }
        it { expect(person.sww_salutation).to eq 'Frau' }
      end

      context 'with gender m' do
        before { person.update(gender: 'm') }
        it { expect(person.sww_salutation).to eq 'Herr' }
      end
    end

    context 'with person language fr' do
      before { person.update(language: :fr) }

      context 'with gender other' do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq 'Autre' }
        it { expect(person.sww_salutation(skip_other: true)).to be_nil }
      end

      context 'with gender f' do
        before { person.update(gender: 'w') }
        it { expect(person.sww_salutation).to eq 'Madame' }
      end

      context 'with gender m' do
        before { person.update(gender: 'm') }
        it { expect(person.sww_salutation).to eq 'Monsieur' }
      end
    end

    context 'with person language it' do
      before { person.update(language: :it) }

      context 'with gender other' do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq 'Altro' }
        it { expect(person.sww_salutation(skip_other: true)).to be_nil }
      end

      context 'with gender f' do
        before { person.update(gender: 'w') }
        it { expect(person.sww_salutation).to eq 'Signora' }
      end

      context 'with gender m' do
        before { person.update(gender: 'm') }
        it { expect(person.sww_salutation).to eq 'Signor' }
      end
    end

    context 'with person language en' do
      before { person.update(language: :en) }

      context 'with gender other' do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq 'Andere' }
      end

      context 'with gender f' do
        before { person.update(gender: 'w') }
        it { expect(person.sww_salutation).to eq 'Frau' }
      end

      context 'with gender m' do
        before { person.update(gender: 'm') }
        it { expect(person.sww_salutation).to eq 'Herr' }
      end
    end
  end
end
