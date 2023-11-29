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
