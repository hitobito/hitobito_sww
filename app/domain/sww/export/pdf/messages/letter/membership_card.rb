#  frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter
  class MembershipCard < Export::Pdf::Messages::Letter::Section

    def render(recipient, options)
      offset_cursor_from_top 4.4.cm
      bounding_box([10.2.cm, cursor], width: 5.7.cm, height: 1.2.cm) do
        text_box([I18n.t('messages.export.pdf.letter.membership_card.title'),
                  recipient.person.member_number,
                  "<b>#{person_or_company_name(recipient)}</b>"].join("\n"),
        inline_format: true, size: 8.pt)
      end
    end

    private

    def person_or_company_name(recipient)
      person = recipient.person
      if person.company?
        person.company_name.to_s.squish
      else
        person.full_name.to_s.squish
      end
    end

  end
end
