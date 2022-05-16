#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter::Header
  extend ActiveSupport::Concern

  def render(recipient, options)
    return super unless letter.membership_card?

    offset_cursor_from_top 4.7.cm
    bounding_box([0, cursor], width: 8.7.cm, height: 2.6.cm) do
      stroke_bounds
      text letter.pp_post

      pdf.move_down 0.7.cm

      render_address(recipient.address)
    end
  end

end
