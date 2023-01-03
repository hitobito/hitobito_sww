# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Person
  extend ActiveSupport::Concern

  included do
    add_public_attrs = [:custom_salutation, :magazin_abo_number, :title, :name_add_on,
                        :sww_cms_profile_id]
    Person::PUBLIC_ATTRS.push(*add_public_attrs)
    Person::INTERNAL_ATTRS << :alabus_id << :member_number

    # member number is already present in legacy system (alabus)
    # and is imported
    # start numbering from this value for people created in hitobito
    INIT_MEMBER_NUMBER = 300_000

    before_validation :set_incremented_member_number,
                      unless: :member_number

    validates :member_number,
              uniqueness: true,
              if: -> { member_number >= INIT_MEMBER_NUMBER }

    attr_readonly :member_number
    attr_readonly :alabus_id
  end

  private

  def set_incremented_member_number
    self.member_number = next_member_number
  end

  def next_member_number
    max_nr = Person.maximum(:member_number) || 1
    if max_nr < INIT_MEMBER_NUMBER
      INIT_MEMBER_NUMBER
    else
      max_nr.succ
    end
  end
end
