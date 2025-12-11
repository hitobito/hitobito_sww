# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Contactable::Address
  def for_pdf_label(name, nickname = false)
    return super unless addressable.is_a?(Person)

    [
      (print_company? ? build_company_block : build_person_block),
      full_address(country_as: :country_label)
    ].compact.join("\n")
  end

  private

  def build_company_block
    [
      contactable.to_s,
      contactable.full_name.presence
    ].compact.join("\n")
  end

  def build_person_block
    [
      contactable.sww_salutation(skip_other: true),
      contactable.to_s,
      contactable.nickname
    ].compact.join("\n")
  end

  def print_company?
    contactable.company? &&
      contactable.company_name.present? &&
      contactable.company_name != contactable.full_name
  end
end
