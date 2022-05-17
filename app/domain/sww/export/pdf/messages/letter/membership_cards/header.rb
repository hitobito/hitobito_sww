#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::MembershipCards
  class Header < Export::Pdf::Messages::Letter::Header

    def render(recipient, options)
      return super unless letter.membership_card?

      offset_cursor_from_top 4.7.cm
      bounding_box([0, cursor], width: 8.7.cm, height: 2.6.cm) do
        shipping_method = shipping_methods[letter.shipping_method.to_sym]
        text_box("<font size='7pt'>#{shipping_method} #{letter.pp_post.upcase} | POST CH AG</font>",
                 inline_format: true, single_line: true)

        pdf.move_down 0.7.cm

        render_address(recipient.address)
      end
    end

    def shipping_methods
      {
        own: '',
        normal: 'P.P.',
        priority: 'P.P. A'
      }
    end

  end
end
