# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Groups::SelfRegistrationController
  extend ActiveSupport::Concern

  prepended do
    helper_method :gender_options
  end

  def person_attrs
    attrs = super
    attrs&.merge(address_from_params)
  end

  def address_from_params
    @street = model_params&.require(:new_person)&.delete(:street)
    @house_number = model_params&.require(:new_person)&.delete(:house_number)
    {
      address: [@street, @house_number].join(' ')
    }
  end

  def gender_options
    [[:w, t('.gender.w')], [:m, t('.gender.m')], [nil, t('.gender.other')]]
  end
end
