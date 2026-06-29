# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe VariousAbility do
  subject { Ability.new(person.reload) }

  context "Group::Mitglieder::Aktivmitglied" do
    let(:person) { people(:berner_wanderer) }

    it "hides settings" do
      is_expected.not_to be_able_to(:index, LabelFormat)
    end
  end

  context "Group::Benutzerkonten::Benutzerkonto" do
    let(:group) { groups(:benutzerkonten) }
    let(:person) {
      Fabricate(Group::Benutzerkonten::Benutzerkonto.sti_name.to_sym, group:).person
    }

    it "hides settings" do
      is_expected.not_to be_able_to(:index, LabelFormat)
    end
  end

  context "Group::Benutzerkonten::Verwalter" do
    let(:group) { groups(:benutzerkonten) }
    let(:person) {
      Fabricate(Group::Benutzerkonten::Verwalter.sti_name.to_sym, group:).person
    }

    it "shows settings" do
      is_expected.to be_able_to(:index, LabelFormat)
    end
  end
end
