class MigrateGroupSettingsSww < ActiveRecord::Migration[6.1]
  def up
    say_with_time("create group attributes") do
      add_column :groups, :letter_left_address_position, :integer
      add_column :groups, :letter_top_address_position, :integer
      add_column :groups, :membership_card_left_position, :integer
      add_column :groups, :membership_card_top_position, :integer

      Group.reset_column_information
    end

    return unless table_exists?(:settings)

    say_with_time("migrate group settings to group attributes") do
      migrate_settings
    end
  end

  def down
    say_with_time("remove group attributes") do
      remove_column :groups, :letter_left_address_position
      remove_column :groups, :letter_top_address_position
      remove_column :groups, :membership_card_left_position
      remove_column :groups, :membership_card_top_position
    end

    Group.reset_column_information
  end
end
