# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe PersonAbility do
  subject { ability }

  let(:ability) { Ability.new(role.person.reload) }

  context "person with only benutzerkonto role" do
    let(:role) do
      Fabricate(Group::Benutzerkonten::Benutzerkonto.sti_name.to_sym,
        group: groups(:benutzerkonten))
    end

    it "may not show_details herself" do
      is_expected.to_not be_able_to(:show_details, role.person)
    end

    it "may not show_full herself" do
      is_expected.to_not be_able_to(:show_full, role.person)
    end

    it "may not show history on herself" do
      is_expected.to_not be_able_to(:history, role.person)
    end

    it "may not show log on herself" do
      is_expected.to_not be_able_to(:log, role.person)
    end

    it "may not index invoices on herself" do
      is_expected.to_not be_able_to(:index_invoices, role.person)
    end
  end
end
