# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class AddSeparatorsToInvoiceConfig < ActiveRecord::Migration[6.1]
  def change
    add_column :invoice_configs, :separators, :boolean, default: true, null: false

    InvoiceConfig.reset_column_information
  end
end
