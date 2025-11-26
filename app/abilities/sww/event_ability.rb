# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event) do
      permission(:group_and_below_full).may(:application_market).in_same_group_or_below_if_active
    end
  end
end
