# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


class ChangeGroupAddressPositionsType < ActiveRecord::Migration[6.1]
  def change
    # These address position columns have been created as integer columns by mistake.
    # Let's change them to float columns.
    change_column :groups, :letter_left_address_position, :float
    change_column :groups, :letter_top_address_position, :float
    change_column :groups, :membership_card_left_position, :float
    change_column :groups, :membership_card_top_position, :float

  end
end
