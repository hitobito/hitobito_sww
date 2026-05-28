# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Sheet::Person do
  let(:person) { people(:berner_wanderer) }

  before do
    allow(controller).to receive(:current_user).and_return(person)
    allow(view).to receive(:current_user).and_return(person)
  end

  subject(:sheet) { Sheet::Person.new(view, person) }

  def tabs = sheet.tabs.map(&:label_key)

  it "does not have the colleagues tab" do
    label_key = "people.tabs.colleagues"
    expect(I18n.t(label_key)).to be_present # sanity check that the label key is correct
    expect(tabs).not_to include(label_key)
  end

  context "when user has basic_permissions_only" do
    let(:security_label_key) { "people.tabs.security_tools" }

    it "has only the info tab" do
      expect(person).to be_basic_permissions_only

      label_key = "global.tabs.info"
      expect(I18n.t(label_key)).to be_present # sanity check
      expect(tabs).to eq [label_key]
    end
  end

  context "when user has more than basic_permissions_only" do
    let(:security_label_key) { "people.tabs.security_tools" }

    it "has the security tab" do
      Fabricate(Group::Benutzerkonten::Verwalter.sti_name,
        group: groups(:benutzerkonten), person: person)
      expect(person).not_to be_basic_permissions_only

      label_key = "people.tabs.security_tools"
      expect(I18n.t(label_key)).to be_present # sanity check
      expect(tabs).to include(label_key)
    end
  end
end
