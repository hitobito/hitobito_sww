#  frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::PersonIndex; end

ThinkingSphinx::Index.define_partial :person do
  indexes '`people`.`magazin_abo_number`', as: :magazin_abo_number
  indexes "CASE WHEN `people`.`manual_member_number` IS NOT NULL " +
          "THEN `people`.`manual_member_number` " +
            "ELSE `people`.`id` + #{Sww::Person::MEMBER_NUMBER_CALCULATION_OFFSET} END",
          as: :member_number
end
