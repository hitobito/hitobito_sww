#  frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class MigrateToGeneratedMemberNumber1 < ActiveRecord::Migration[6.1]
  def change
    rename_column :people, :member_number, :manual_member_number
  end
end
