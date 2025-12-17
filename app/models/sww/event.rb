# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Event
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:automatic_assignment, :waiting_list]
    self.supports_applications = true

    def group_names
      groups.map(&:layer_group).join(", ")
    end
  end
end
