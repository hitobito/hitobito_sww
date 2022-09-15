# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

module Sww::GroupSetting
  extend ActiveSupport::Concern

  included do
    GroupSetting::SETTINGS.deep_merge!({
      messages_letter: { 
        left_address_offset: nil,
        top_address_offset: nil
      },
      membership_card: {
        left_offset: nil,
        top_offset: nil
      }
    })

    def left_offset_type
      :number
    end

    def top_offset_type
      :number
    end

    def left_address_offset_type
      :number
    end

    def top_address_offset_type
      :number
    end

  end

end
