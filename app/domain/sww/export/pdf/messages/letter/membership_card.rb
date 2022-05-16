#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter
  class MembershipCard < Export::Pdf::Messages::Letter::Section

    def render(recipient, options)
      offset_cursor_from_top 4.4.cm
      bounding_box([10.2.cm, cursor], width: 5.7.cm, height: 1.2.cm) do
        text ['Carte de lecteur WANDERN.ch',
              recipient.person.member_number,
              recipient.person.full_name].join("\n")

        stroke_bounds
      end
    end

  end
end
