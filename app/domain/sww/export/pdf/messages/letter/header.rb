#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::Header
  def render_address(recipient,
    width: Export::Pdf::Messages::Letter::Header::ADDRESS_BOX.first,
    height: Export::Pdf::Messages::Letter::Header::ADDRESS_BOX.second)
    return super if recipient.person&.gender.blank?

    bounding_box([0, cursor], width: width, height: height) do
      text [recipient.person&.sww_salutation, recipient.address].join("\n")
    end
  end
end
