#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::MembershipCards
  class Content < Export::Pdf::Messages::Letter::Content

    SUBJECT_WIDTH = 12.8.cm

    def render(recipient, options)
      stamped(:date_location_text)

      stamped(:subject)

      stamped(:body)
    end

    def date_location_text
      offset_cursor_from_top 11.2.cm
      bounding_box([SUBJECT_WIDTH, cursor], width: bounds.width - SUBJECT_WIDTH, height: 0.5.cm) do
        text_box("<font size='10pt'>#{letter.date_location_text}</font>",
                 inline_format: true)
      end
    end

    def subject
      offset_cursor_from_top 12.cm
      bounding_box([0, cursor], width: SUBJECT_WIDTH, height: 2.cm) do
        text_box("<b>#{letter.subject.upcase}</b>",
                 inline_format: true, size: 15.pt)
      end
    end

    def body
      offset_cursor_from_top 14.cm
      bounding_box([0, cursor], width: bounds.width, height: 13.cm) do
        pdf.markup(letter.body.to_s)
      end
    end
  end
end
