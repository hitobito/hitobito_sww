#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class AddEventSenderEmailToGroup < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :event_sender_email, :string
  end
end
