#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::Content
  extend ActiveSupport::Concern

  def render(recipient, options)
    return super unless letter.membership_card?

    offset_cursor_from_top 11.3.cm
    left = 12.8.cm
    bounding_box([left, cursor], width: bounds.width - left, height: 0.5.cm) do
      stroke_bounds
      text letter.date_location_text
    end
    offset_cursor_from_top 12.cm
    bounding_box([0, cursor], width: bounds.width, height: 15.cm) do
      stroke_bounds
      text letter.subject
      pdf.markup(letter.body.to_s)
    end
  end

end
