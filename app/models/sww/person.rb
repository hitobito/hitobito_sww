# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Person
  extend ActiveSupport::Concern

  MEMBER_NUMBER_CALCULATION_OFFSET = 300_000

  included do
    add_public_attrs = [:custom_salutation, :magazin_abo_number, :title, :name_add_on,
                        :sww_cms_profile_id]
    Person::PUBLIC_ATTRS.push(*add_public_attrs)
    Person::INTERNAL_ATTRS << :alabus_id << :member_number << :manual_member_number

    attr_readonly :alabus_id
    
    validates :manual_member_number,
              uniqueness: true,
              allow_nil: true,
              numericality: { less_than: MEMBER_NUMBER_CALCULATION_OFFSET }
  end

  def member_number
    manual_member_number || id &.+(MEMBER_NUMBER_CALCULATION_OFFSET)
  end
end
