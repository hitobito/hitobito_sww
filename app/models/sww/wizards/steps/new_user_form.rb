# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Wizards::Steps::NewUserForm
  extend ActiveSupport::Concern
  prepended do
    attribute :gender, :string
    attribute :birthday, :date
    attribute :address_care_of, :string
    attribute :street, :string
    attribute :housenumber, :string

    attribute :postbox, :string
    attribute :zip_code, :string
    attribute :town, :string
    attribute :country, :string

    validates :gender, :email, :first_name, :last_name, presence: true

    def gender_options
      [[:w, I18n.t("groups.self_registration.new.gender.w")], [:m, I18n.t("groups.self_registration.new..gender.m")], [nil, I18n.t("groups.self_registration.new.gender.other")]]
    end

    def assignable_attributes
      attributes.compact_blank.symbolize_keys.except(:adult_consent)
    end
  end
end
