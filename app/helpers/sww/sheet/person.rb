# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Sww::Sheet::Person
  def tabs
    if view.current_user&.basic_permissions_only?
      # For basic_permissions_only users, show only the info tab
      super.select { |t| t.label_key == "global.tabs.info" }
    else
      # Never show the colleagues tab in SWW
      super.reject { |t| t.label_key == "people.tabs.colleagues" }
    end
  end
end
