# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe "people/_attrs.html.haml" do
  let(:group) { groups(:berner_mitglieder) }
  let(:current_user) { people(:berner_wanderer) }

  subject do
    render
    Capybara::Node::Simple.new(@rendered)
  end

  before do
    assign(:group, group)
    assign(:tags, [])
    allow(view).to receive_messages(parent: group.parent)
    allow(view).to receive_messages(entry: PersonDecorator.decorate(current_user))
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(view).to receive(:current_user).and_return(current_user)
  end

  it "viewed by person with more than basic_permissions_only shows timestamps" do
    Fabricate(Group::Benutzerkonten::Verwalter.name.to_s, group: groups(:benutzerkonten),
      person: current_user)
    expect(current_user).not_to be_basic_permissions_only

    is_expected.to have_content "Erstellt"
    is_expected.to have_content "Geändert"
  end

  it "viewed by person with basic_permissions_only does not show timestamps" do
    expect(current_user).to be_basic_permissions_only

    is_expected.not_to have_content "Erstellt"
    is_expected.not_to have_content "Geändert"
  end
end
