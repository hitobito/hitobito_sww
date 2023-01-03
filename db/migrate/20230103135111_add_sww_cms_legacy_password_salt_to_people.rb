#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class AddSwwCmsLegacyPasswordSaltToPeople < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :sww_cms_legacy_password_salt, :string, null: true
  end
end
