# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Person
  extend ActiveSupport::Concern

  included do
    add_public_attrs = [:magazin_abo_number, :title]
    Person::PUBLIC_ATTRS.push(*add_public_attrs)

    add_internal_attrs = [:alabus_id, :member_number,
      :sww_cms_profile_id, :sww_cms_legacy_password_salt,
      :custom_salutation, :name_add_on]
    Person::INTERNAL_ATTRS.push(*add_internal_attrs)

    Person::SEARCHABLE_ATTRS << :magazin_abo_number

    alias_attribute :member_number, :id

    attr_readonly :alabus_id

    validates :sww_cms_profile_id,
      uniqueness: true,
      allow_nil: true

    belongs_to :updated_by, class_name: "Person", foreign_key: :updater_id
  end

  def sww_salutation(skip_other: false)
    key = skip_other ? gender : (gender || "other")
    if key
      I18n.t("groups.self_registration.new.gender.#{key}",
        locale: language.presence || I18n.default_locale)
    end
  end
end
