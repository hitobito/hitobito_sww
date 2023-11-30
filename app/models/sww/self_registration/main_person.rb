# frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::SelfRegistration::MainPerson
  extend ActiveSupport::Concern

  prepended do
    self.attrs += [
      :first_name, :last_name, :company_name, :company,
      :birthday,
      :street, :house_number,
      :gender,
      :email,
      :address, :zip_code, :town, :country,
    ]

    self.required_attrs = [
      :gender, :first_name, :last_name, :email
    ]

    attr_accessor(*attrs) # needs to be called for new attr accessors to be created
  end

  def person
    street = attributes.delete(:street)
    house_number = attributes.delete(:house_number)
    address = [street, house_number].compact.join(' ')
    Person.new(attributes.merge(address: address))
  end

  def gender_options
    [[:w, t('.gender.w')], [:m, t('.gender.m')], [nil, t('.gender.other')]]
  end

  private

  def attributes
    @attributes ||= super
  end

  def t(key)
    I18n.t(key, scope: 'groups.self_registration.new')
  end
end
