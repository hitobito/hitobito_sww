# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Sheet::Person do
  let(:person) { people(:berner_wanderer) }
  let(:label_key) { "people.tabs.colleagues" }

  subject(:sheet) { Sheet::Person.new(self, person) }

  def tabs = sheet.tabs.map(&:label_key)

  it "does not have the colleagues tab" do
    expect(I18n.t(label_key)).to be_present # sanity check that the label key is correct
    expect(tabs).not_to include(label_key)
  end
end
