# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Export::Tabular::People::PersonRow do

  let(:person) { people(:berner_wanderer) }
  let(:row) { described_class.new(person) }

  subject { row }

  context 'sww salutation' do
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
end
