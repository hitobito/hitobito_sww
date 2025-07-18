# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::MembershipCards
  class Header < Export::Pdf::Messages::Letter::Header
    include Export::Pdf::AddressRenderers
    LEFT_ADDRESS_X = 0
    RIGHT_ADDRESS_X = 10.2.cm

    def render(recipient, _options)
      offset_cursor_from_top 4.7.cm
      bounding_box(address_position(group.letter_address_position), width: 8.7.cm, height: 2.6.cm) do
        stamped(:shipping_text)

        pdf.move_down 0.7.cm

        render_address(recipient)
      end
    end

    def shipping_text
      text_box("<font size='7'>#{shipping_method} #{letter.pp_post&.upcase} | POST CH AG</font>",
        inline_format: true, single_line: true)
    end

    def shipping_method
      @shipping_method ||= {
        own: "",
        normal: "P.P.",
        priority: "P.P. A"
      }[letter.shipping_method.to_sym]
    end

    # Has to be overriden as to not use sww_salutation
    def render_address(recipient, width: ADDRESS_BOX.first, height: ADDRESS_BOX.second)
      bounding_box([0, cursor], width: width, height: height) do
        text recipient.address
      end
    end
  end
end
