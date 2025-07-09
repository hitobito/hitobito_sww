# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require 'spec_helper'

describe Invoice do
  it 'allows payments even if it is paid' do
    expect(described_class::STATES_PAYABLE).to include('payed')
  end

  it 'allows payement if it is overpaid' do
    expect(described_class::STATES_PAYABLE).to include('excess')
  end
end
