# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

module Sww::GroupSetting
  extend ActiveSupport::Concern

  included do
    GroupSetting::SETTINGS.deep_merge!(
      messages_letter: {
        left_address_position: nil,
        top_address_position: nil
      },
      membership_card: {
        left_position: nil,
        top_position: nil
      }
    )

    def left_position_type
      :positive_number
    end

    def top_position_type
      :positive_number
    end

    def left_address_position_type
      :positive_number
    end

    def top_address_position_type
      :positive_number
    end
  end
end
