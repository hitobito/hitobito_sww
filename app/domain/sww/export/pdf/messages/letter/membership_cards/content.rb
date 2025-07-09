# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::MembershipCards
  class Content < Export::Pdf::Messages::Letter::Content
    SUBJECT_WIDTH = 12.8.cm

    def render(recipient, _options)
      offset_cursor_from_top 11.2.cm

      stamped(:date_location_text)

      offset_cursor_from_top 12.cm

      unless letter.invoice?
        stamped(:subject)

        pdf.move_down 0.5.cm
      end

      render_salutation(recipient) if letter.salutation?
      stamped(:body)
    end

    def date_location_text
      bounding_box([SUBJECT_WIDTH, cursor], width: bounds.width - SUBJECT_WIDTH, height: 0.5.cm) do
        text_box("<font size='10'>#{letter.date_location_text}</font>",
          inline_format: true)
      end
    end

    def subject
      text(letter.subject.upcase, size: 15.pt, style: :bold)
    end

    def body
      pdf.markup(letter.body.to_s)
    end
  end
end
