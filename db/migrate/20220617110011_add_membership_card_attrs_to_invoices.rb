# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


class AddMembershipCardAttrsToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :membership_card, :boolean, default: false, null: false
    add_column :invoices, :membership_expires_on, :date
  end
end
