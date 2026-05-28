# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Sww::PersonDecorator do
  let(:person) { people(:berner_wanderer) }
  let(:decorator) { PersonDecorator.new(person) }

  before { allow(decorator).to receive(:current_user).and_return(person) }

  context "as user with basic_permissions_only" do
    before { expect(person).to be_basic_permissions_only }

    it "#created_info returns nil" do
      expect(decorator.created_info).to be_nil
    end

    it "#updated_info returns nil" do
      expect(decorator.updated_info).to be_nil
    end
  end

  context "as user with more than basic_permissions_only" do
    before do
      Fabricate(Group::Benutzerkonten::Verwalter.name.to_s, group: groups(:benutzerkonten),
        person: person)
      expect(person).not_to be_basic_permissions_only
    end

    it "#created_info returns the created info" do
      expect(decorator.created_info).to be_present
    end

    it "#updated_info returns the updated info" do
      expect(decorator.updated_info).to be_present
    end
  end
end
