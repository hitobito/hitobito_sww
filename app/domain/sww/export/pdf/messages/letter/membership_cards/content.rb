#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::MembershipCards
  class Content < Export::Pdf::Messages::Letter::Content

    def render(recipient, options)
      offset_cursor_from_top 11.2.cm
      left = 12.8.cm
      bounding_box([left, cursor], width: bounds.width - left, height: 0.5.cm) do
        text_box("<font size='10pt'>#{letter.date_location_text}</font>",
                 inline_format: true)
      end

      offset_cursor_from_top 12.cm
      bounding_box([0, cursor], width: left, height: 2.cm) do
        text_box("<b>#{letter.subject.upcase}</b>",
                 inline_format: true, size: 15.pt)
      end

      offset_cursor_from_top 14.cm
      bounding_box([0, cursor], width: bounds.width, height: 13.cm) do
        pdf.markup(letter.body.to_s)
      end
    end
  end
end
