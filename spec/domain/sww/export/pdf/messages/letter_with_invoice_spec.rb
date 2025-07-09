# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require 'spec_helper'

describe Export::Pdf::Messages::LetterWithInvoice do
  let(:options) { {} }
  let(:analyzer) { PDF::Inspector::Text.analyze(subject.render) }

  describe 'membership_card' do

    before do
      Subscription.create!(
        subscriber: groups(:zuercher_mitglieder),
        mailing_list: letter.mailing_list,
        role_types: [Group::Mitglieder::Aktivmitglied]
      )
    end

    let(:recipient) { people(:top_leader) }

    subject { Export::Pdf::Messages::LetterWithInvoice.new(letter, options) }

    let!(:invoice_config) {
      InvoiceConfig.create!(group: letter.group,
                            sequence_number: 1,
                            address: "Puzzle\nBelpstrasse 37\n3007 Bern",
                            iban: 'CH93 0030 0111 6238 5295 7',
                            account_number: '10-5318-5',
                            payment_slip: 'qr',
                            payee: "Puzzle ITC\nBelpstrasse 37\n3007 Bern"
                           )
    }

    let(:letter) do
      letter_attrs = messages(:membership_card_letter).attributes.except('type', 'id')
      attrs = letter_attrs.merge(body: messages(:membership_card_letter).body,
                                 invoice_attributes: {
                                   'invoice_items_attributes' => {
                                     1 => {
                                       name: 'Mitgliederbeitrag',
                                       unit_cost: 150,
                                       count: 1
                                     }
                                   }
                                 })

      Message::LetterWithInvoice.create!(attrs)
    end

    before do
      Messages::LetterWithInvoiceDispatch.new(letter).run
    end

    context 'rendered left' do
      before do
        letter.group.letter_address_position = :left
        letter.group.save!
      end

      it 'renders the membership card on the left' do
        membership_card = [
          [346, 721, "Mitgliederausweis"],
          [346, 710, "42431"],
          [346, 699, "Alice Bar"],
          [511, 721, "Gültig bis"],
          [517, 710, "12.2042"],
        ]

        expect(text_with_position).to include(*membership_card)
      end

      it 'moves the address to the right' do
        expect(text_with_position).to include([57, 703, "P.P.  | POST CH AG"])
      end
    end

    context 'rendered right' do
      before do
        letter.group.letter_address_position = :right
        letter.group.save!
      end

      it 'renders the membership card on the right' do
        membership_card = [
          [57, 721, "Mitgliederausweis"],
          [57, 710, "42431"],
          [57, 699, "Alice Bar"],
          [222, 721, "Gültig bis"],
          [227, 710, "12.2042"]
        ]

        expect(text_with_position).to include(*membership_card)
      end

      it 'moves the address to the left' do
        expect(text_with_position).to include([347, 703, "P.P.  | POST CH AG"])
      end
    end

    context 'rendered at custom position' do
      before do
        letter.group.letter_left_address_position = 3 # 3.cm = 85
        letter.group.letter_top_address_position = 5

        letter.group.membership_card_left_position = 10
        letter.group.membership_card_top_position = 5
        letter.group.save!
      end

      it 'has assumptions' do
        expect(29.7.cm.round).to eq 842
        expect(21.0.cm.round).to eq 595

        expect(3.cm.round).to eq 85
        expect(5.cm.round).to eq 142
        expect(10.cm.round).to eq 283

        expect((21.cm - 3.cm).round).to eq 510 # 3cm left
        expect((21.cm - 10.cm).round).to eq 312 # 10cm left
        expect((29.7.cm - 5.cm).round).to eq 700 # 5cm top

        # actual and follow-up positions are dependent on the font, font-size,
        # font-style and content. this is just a ball-park to start looking.
      end

      it 'renders membership card at the custom position' do
        membership_card = [
          [283, 693, "Mitgliederausweis"],
          [283, 681, "42431"],
          [283, 670, "Alice Bar"],
          [449, 693, "Gültig bis"],
          [454, 681, "12.2042"]
        ]

        expect(text_with_position).to include(*membership_card)
      end

      it 'moves the address to the custom position' do
        expect(text_with_position).to include([85, 695, "P.P.  | POST CH AG"])
      end
    end
  end

  private

  def text_with_position
    analyzer.positions.each_with_index.collect do |p, i|
      p.collect(&:round) + [analyzer.show_text[i]]
    end
  end
end
