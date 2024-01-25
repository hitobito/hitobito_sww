#  frozen_string_literal: true

#  Copyright (c) 2022-2024, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter
  class MembershipCard < Export::Pdf::Section
    include Export::Pdf::AddressRenderers
    self.left_address_x = 10.2.cm
    self.right_address_x = 0

    def render(message_recipient = nil, _options = {}) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      recipient = fetch_recipient(message_recipient)
      offset_cursor_from_top 4.cm
      bounding_box(address_position(model.group), width: 5.7.cm, height: 1.2.cm) do
        pdf.font('Helvetica') do
          text_box(card_title(recipient),
                   inline_format: true, size: 10.pt)

          bounding_box([0.cm, 0.4.cm], width: 7.3.cm, height: 0.6.cm) do
            text_box(person_or_company_name(recipient),
                     inline_format: true, size: 10.pt,
                     overflow: :shrink_to_fit, min_font_size: 5.pt)
          end

          bounding_box([5.3.cm, 1.2.cm], width: 2.0.cm, height: 1.2.cm) do
            text_box(valid_until(membership_expires_on),
                     inline_format: true, size: 10.pt, align: :right)
          end
        end
      end
    end

    private

    def person_or_company_name(person)
      if person.company?
        person.company_name.to_s.squish
      else
        person.full_name.to_s.squish
      end
    end

    def valid_until(membership_expires_on)
      [
        I18n.t('messages.export.pdf.letter.membership_card.valid_until'),
        membership_expires_on
      ].join("\n")
    end

    def card_title(person)
      [
        "<b>#{I18n.t('messages.export.pdf.letter.membership_card.title')}</b>",
        person.member_number
      ].join("\n")
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

    def left_position(group)
      group.membership_card_left_position
    end

    def top_position(group)
      group.membership_card_top_position
    end
  end
end
