# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Person
  extend ActiveSupport::Concern

  MEMBER_NUMBER_CALCULATION_OFFSET = 300_000

  included do
    add_public_attrs = [:custom_salutation, :magazin_abo_number, :title,
      :name_add_on]
    Person::PUBLIC_ATTRS.push(*add_public_attrs)

    add_internal_attrs = [:alabus_id, :member_number, :manual_member_number,
      :sww_cms_profile_id, :sww_cms_legacy_password_salt]
    Person::INTERNAL_ATTRS.push(*add_internal_attrs)

    Person::MERGABLE_ATTRS << :manual_member_number

    Person::SEARCHABLE_ATTRS << :magazin_abo_number << :manual_member_number

    attr_readonly :alabus_id

    validates :manual_member_number,
      uniqueness: true,
      allow_nil: true,
      numericality: {less_than: MEMBER_NUMBER_CALCULATION_OFFSET}

    validates :sww_cms_profile_id,
      uniqueness: true,
      allow_nil: true

    belongs_to :updated_by, class_name: "Person", foreign_key: :updater_id

    alias_method_chain :finance_groups, :complete_finance_permission
  end

  def member_number
    manual_member_number || id&.+(MEMBER_NUMBER_CALCULATION_OFFSET)
  end

  def finance_groups_with_complete_finance_permission
    if groups_with_permission(:complete_finance).any?
      Group.where(type: Group.all_types.select(&:layer).map(&:sti_name)).to_a
    else
      finance_groups_without_complete_finance_permission
    end
  end

  def sww_salutation(skip_other: false)
    key = skip_other ? gender : (gender || "other")
    I18n.t("groups.self_registration.new.gender.#{key}", locale: language) if key
  end
end
