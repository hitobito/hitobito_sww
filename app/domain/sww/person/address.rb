# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Person::Address
  def for_pdf_label(name, nickname = false)
    return super unless addressable.is_a?(Person)

    [
      company_name_or_sww_gender_infered_salutation,
      (person.nickname if print_nickname?(nickname)),
      person_name(name).presence,
      short_address(country_as: :country_label)
    ].compact.join("\n")
  end

  private

  # NOTE:: re-evaluate when refactoring core, passing name from Export::Tabular::People::HouseholdRow
  # passing company_name as name feels rather strange and forces us to customize here
  def person_name(name)
    return name unless name == person.company_name

    person.full_name
  end

  def print_company?
    person.company? && person.company_name.present? && person.company_name != person.full_name
  end

  def company_name_or_sww_gender_infered_salutation
    print_company? ? person.company_name : person.sww_salutation(skip_other: true)
  end
end
