# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe :sign_in_logo, js: false do
  context "without oauth" do
    it "should show logo" do
      visit new_person_session_path
      expect(page).to have_css("a.logo-image")
    end
  end

  context "with oauth" do
    it "should not show logo" do
      visit new_person_session_path(oauth: true)
      expect(page).not_to have_css("a.logo-image")
    end
  end
end
