# frozen_string_literal: true

#  Copyright (c) 2012-2024, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::SelfRegistration::MainPerson
  extend ActiveSupport::Concern

  prepended do
    self.required_attrs = [
      :gender, :first_name, :last_name, :email
    ]

    self.attrs += [
      :first_name, :last_name, :company_name, :company,
      :birthday,
      :address_care_of,
      :street, :housenumber,
      :postbox,
      :gender,
      :email,
      :zip_code, :town, :country
    ]
  end

  def gender_options
    [[:w, t(".gender.w")], [:m, t(".gender.m")], [nil, t(".gender.other")]]
  end

  private

  def t(key)
    I18n.t(key, scope: "groups.self_registration.new")
  end
end
