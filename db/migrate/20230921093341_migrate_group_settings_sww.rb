# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


class MigrateGroupSettingsSww < ActiveRecord::Migration[6.1]
  def up
    say_with_time("create group attributes") do
      add_column :groups, :letter_left_address_position, :integer
      add_column :groups, :letter_top_address_position, :integer
      add_column :groups, :membership_card_left_position, :integer
      add_column :groups, :membership_card_top_position, :integer
    end
  end

  def down
    say_with_time("remove group attributes") do
      remove_column :groups, :letter_left_address_position
      remove_column :groups, :letter_top_address_position
      remove_column :groups, :membership_card_left_position
      remove_column :groups, :membership_card_top_position
    end
  end
end
