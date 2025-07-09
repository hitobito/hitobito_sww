# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe "Dropdown::PeopleExport" do
  include FormatHelper
  include LayoutHelper
  include UtilityHelper

  let(:dropdown) do
    html = Dropdown::PeopleExport.new(self,
      people(:zuercher_leiter),
      {controller: "event/participations",
       group_id: groups(:zuercher_mitglieder).id,
       event_id: events(:top_course).id},
      {details: details}).to_s

    Capybara.string(html)
  end

  context "when details permission is present" do
    let(:details) { true }

    it "contains participations list" do
      expect(submenu_entries(dropdown, "Excel")).to match_array ["Adressliste", "Alle Angaben", "Spaltenauswahl", "Teilnehmerliste"]
    end
  end

  context "when details permission is missing" do
    let(:details) { false }

    it "does not contain participation list" do
      expect(submenu_entries(dropdown, "Excel")).to match_array ["Adressliste", "Spaltenauswahl"]
    end
  end

  private

  def submenu_entries(dropdown, name)
    menu = dropdown.find(".btn-group > ul.dropdown-menu")
    menu.all("> li > a:contains('#{name}') ~ ul > li > a").map(&:text)
  end
end
