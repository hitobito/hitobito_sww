#  frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter
  class MembershipCard < Export::Pdf::Section

    def render(message_recipient = nil, _options = {})
      recipient = fetch_recipient(message_recipient)
      offset_cursor_from_top 4.cm
      bounding_box([10.2.cm, cursor], width: 5.7.cm, height: 1.2.cm) do
        text_box(["<b>#{I18n.t('messages.export.pdf.letter.membership_card.title')}</b>",
                  recipient.member_number,
                  "<b>#{person_or_company_name(recipient)}</b>"].join("\n"),
                 inline_format: true, size: 10.pt)
      end
      render_valid_until
    end

    private

    def render_valid_until
      offset_cursor_from_top 4.4.cm
      bounding_box([15.5.cm, cursor], width: 2.0.cm, height: 1.2.cm) do
        text_box([I18n.t('messages.export.pdf.letter.membership_card.valid_until'),
                 membership_expires_on].join("\n"),
                 inline_format: true, size: 10.pt, align: :right)
      end
    end

    def person_or_company_name(person)
      if person.company?
        person.company_name.to_s.squish
      else
        person.full_name.to_s.squish
      end
    end

    def membership_expires_on
      model.membership_expires_on.try(:strftime, '%m.%Y')
    end

    def fetch_recipient(message_recipient)
      case model
      when Invoice then model.recipient
      when Message then message_recipient.person
      end

    end

  end
end
