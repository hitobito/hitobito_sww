# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class MoveAddressCareOfToAddressAddition < ActiveRecord::Migration[8.0]
  COLUMNS = {
    people: %w[address_care_of address_addition],
    groups: %w[address_care_of address_addition],
    additional_addresses: %w[address_care_of address_addition],
    event_guests: %w[address_care_of address_addition],
    invoices: %w[recipient_address_care_of recipient_address_addition]
  }.freeze

  CARE_OF_PREFIX = '^\s*(c\s*/\s*o|c\.\s*o\.|p\.\s*a\.|bei\s|chez\s|presso\s|z\.?\s*hd|z\.\s*h\.|' \
    'zu\s*handen|attn|att\.|à l.attention|a l.attention|all.attenzione)'

  def up
    COLUMNS.each do |table, (care_of, addition)|
      execute <<~SQL
        UPDATE #{table} SET #{addition} = #{care_of}, #{care_of} = NULL
        WHERE trim(#{care_of}) <> '' AND #{care_of} !~* '#{CARE_OF_PREFIX}'
      SQL
    end
  end

  def down
    COLUMNS.each do |table, (care_of, addition)|
      execute <<~SQL
        UPDATE #{table} SET #{care_of} = #{addition}, #{addition} = NULL
        WHERE #{addition} IS NOT NULL AND #{care_of} IS NULL
      SQL
    end
  end
end
