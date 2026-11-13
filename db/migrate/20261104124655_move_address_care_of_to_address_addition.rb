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
    event_guests: %w[address_care_of address_addition]
  }.freeze

  # Values starting with a c/o or attention prefix stay c/o addresses. Accented capitals are
  # listed explicitly, as case insensitive matching of them depends on the db locale.
  CARE_OF_PREFIXES = [
    'c\s*/\s*[o0]\M', 'c\.\s*o\.', "℅", 'p\.\s*a\.', 'bei\s', 'chez\s', 'presso\s',
    'z\.?\s*hd', 'z\.\s*h\M', 'zu\s*handen', "attn", 'att\.', '[aàÀ]\s*l.\s*att',
    'all.\s*attenzione'
  ].freeze

  CARE_OF_PREFIX = "^\\s*(#{CARE_OF_PREFIXES.join("|")})"

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
