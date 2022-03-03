#  frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class AddCustomAttributesToPerson < ActiveRecord::Migration[6.1]

  def change

    add_column :people, :alabus_id, :string, index: { unique: true }
    add_column :people, :member_number, :integer, index: true, null: false
    add_column :people, :custom_salutation, :string
    add_column :people, :magazin_abo_number, :integer, index: true

  end

end
