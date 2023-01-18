# frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Event do
  subject(:event) { described_class.new }
  subject(:event_without_waiting_list) { described_class.new(waiting_list: false) }

  it 'can have a waiting-list, generally' do
    expect(described_class.supports_applications).to be true
    expect(described_class).to be_attr_used(:waiting_list)
  end

  it 'does have an activated waiting-list by default' do
    expect(event).to be_waiting_list_available
  end

  it 'can deactivate the waiting-list' do
    expect(event_without_waiting_list).to_not be_waiting_list_available
  end
end