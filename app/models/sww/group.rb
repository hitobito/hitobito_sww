# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::Group
  extend ActiveSupport::Concern

  included do
    # Define additional used attributes
    self.used_attributes += [:letter_left_address_position, :letter_top_address_position,
                             :membership_card_left_position, :membership_card_top_position]
    # self.superior_attributes = [:bank_account]

    root_types Group::SchweizerWanderwege

    validates :letter_left_address_position, numericality: { greater_than: 0, allow_nil: true }
    validates :letter_top_address_position, numericality: { greater_than: 0, allow_nil: true }
    validates :membership_card_left_position, numericality: { greater_than: 0, allow_nil: true }
    validates :membership_card_top_position, numericality: { greater_than: 0, allow_nil: true }

  end

end
