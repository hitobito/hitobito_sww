# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe GroupDecorator, :draper_with_helpers do
  describe "allowed_roles_for_self_registration" do
    it "does not include StagingUser" do
      decorator = GroupDecorator.new(groups(:benutzerkonten))

      expect(decorator.allowed_roles_for_self_registration).to match_array [Group::Benutzerkonten::Benutzerkonto]
    end
  end

  describe "possible_roles" do
    let(:current_user) { Fabricate(Group::SchweizerWanderwege::Support.sti_name.to_sym, group: groups(:schweizer_wanderwege)).person }

    it "contains StagingUser" do
      decorator = GroupDecorator.new(groups(:benutzerkonten))
      expect(decorator).to receive_message_chain(:helpers, :action_name).and_return(:new)

      expect(decorator.possible_roles(person: people(:zuercher_leiter))).to match_array [Group::Benutzerkonten::StagingUser, Group::Benutzerkonten::Verwalter]
    end
  end
end
