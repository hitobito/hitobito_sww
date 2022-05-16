#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::Section
  extend ActiveSupport::Concern

  def offset_cursor_from_top(offset)
    margin = letter.membership_card? ?
      Export::Pdf::Messages::Letter::MEMBERSHIP_CARD_MARGIN :
      Export::Pdf::Messages::Letter::MARGIN
    position = pdf.bounds.top - (offset - margin)

    pdf.move_cursor_to position
  end
end
