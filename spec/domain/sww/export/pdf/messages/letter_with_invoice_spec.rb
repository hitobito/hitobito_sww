# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
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
        letter.group.settings(:messages_letter).address_position = :left
        letter.group.save!
      end

      it 'renders membership card in addition to letter' do
        expected_content =
          [[346, 721, "Mitgliederausweis"],
           [346, 710, "42431"],
           [346, 699, "Alice Bar"],
           [511, 721, "Gültig bis"],
           [517, 710, "12.2042"],
           [57, 704, "P.P.  | POST CH AG"],
           [57, 682, "Alice Bar"],
           [57, 672, "Belpstrasse 37"],
           [57, 662, "8001 Zürich"],
           [420, 517, "Bern, 17. Mai 2022"],
           [57, 495, "Hallo"],
           [57, 474, "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! "],
           [57, 454, "Bis bald"],
           [14, 276, "Empfangsschein"],
           [14, 251, "Konto / Zahlbar an"],
           [14, 239, "CH93 0030 0111 6238 5295 7"],
           [14, 228, "Puzzle ITC"],
           [14, 216, "Belpstrasse 37"],
           [14, 205, "3007 Bern"],
           [14, 173, "Zahlbar durch"],
           [14, 161, "Alice Bar"],
           [14, 150, "Belpstrasse 37"],
           [14, 138, "8001 Zürich"],
           [14, 89, "Währung"],
           [71, 89, "Betrag"],
           [14, 78, "CHF"],
           [71, 78, "150.00"],
           [105, 39, "Annahmestelle"],
           [190, 276, "Zahlteil"],
           [190, 89, "Währung"],
           [247, 89, "Betrag"],
           [190, 78, "CHF"],
           [247, 78, "150.00"],
           [346, 278, "Konto / Zahlbar an"],
           [346, 266, "CH93 0030 0111 6238 5295 7"],
           [346, 255, "Puzzle ITC"],
           [346, 243, "Belpstrasse 37"],
           [346, 232, "3007 Bern"],
           [346, 211, "Referenznummer"],
           [346, 200, "00 00542 00303 80000 00000 00019"],
           [346, 178, "Zahlbar durch"],
           [346, 167, "Alice Bar"],
           [346, 155, "Belpstrasse 37"],
           [346, 144, "8001 Zürich"]]

        expect(text_with_position).to eq(expected_content)
      end
    end

    context 'rendered right' do
      before do
        letter.group.settings(:messages_letter).address_position = :right
        letter.group.save!
      end

      it 'renders membership card in addition to letter' do
        expected_content = 
          [[57, 721, "Mitgliederausweis"],
           [57, 710, "42431"],
           [57, 699, "Alice Bar"],
           [222, 721, "Gültig bis"],
           [227, 710, "12.2042"],
           [347, 704, "P.P.  | POST CH AG"],
           [347, 682, "Alice Bar"],
           [347, 672, "Belpstrasse 37"],
           [347, 662, "8001 Zürich"],
           [420, 517, "Bern, 17. Mai 2022"],
           [57, 495, "Hallo"],
           [57, 474, "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! "],
           [57, 454, "Bis bald"],
           [14, 276, "Empfangsschein"],
           [14, 251, "Konto / Zahlbar an"],
           [14, 239, "CH93 0030 0111 6238 5295 7"],
           [14, 228, "Puzzle ITC"],
           [14, 216, "Belpstrasse 37"],
           [14, 205, "3007 Bern"],
           [14, 173, "Zahlbar durch"],
           [14, 161, "Alice Bar"],
           [14, 150, "Belpstrasse 37"],
           [14, 138, "8001 Zürich"],
           [14, 89, "Währung"],
           [71, 89, "Betrag"],
           [14, 78, "CHF"],
           [71, 78, "150.00"],
           [105, 39, "Annahmestelle"],
           [190, 276, "Zahlteil"],
           [190, 89, "Währung"],
           [247, 89, "Betrag"],
           [190, 78, "CHF"],
           [247, 78, "150.00"],
           [346, 278, "Konto / Zahlbar an"],
           [346, 266, "CH93 0030 0111 6238 5295 7"],
           [346, 255, "Puzzle ITC"],
           [346, 243, "Belpstrasse 37"],
           [346, 232, "3007 Bern"],
           [346, 211, "Referenznummer"],
           [346, 200, "00 00542 00303 80000 00000 00019"],
           [346, 178, "Zahlbar durch"],
           [346, 167, "Alice Bar"],
           [346, 155, "Belpstrasse 37"],
           [346, 144, "8001 Zürich"]]

        expect(text_with_position).to eq(expected_content)
      end
    end

    context 'rendered at custom position' do
      before do
        letter.group.settings(:messages_letter).left_address_position = 3 # 3.cm = 85
        letter.group.settings(:messages_letter).top_address_position = 5

        letter.group.settings(:membership_card).left_position = 10
        letter.group.settings(:membership_card).top_position = 5
        letter.group.save!
      end

      it 'renders membership card in addition to letter' do
        expected_content = 
          [[283, 693, "Mitgliederausweis"],
           [283, 681, "42431"],
           [283, 670, "Alice Bar"],
           [449, 693, "Gültig bis"],
           [454, 681, "12.2042"],
           [85, 695, "P.P.  | POST CH AG"],
           [85, 674, "Alice Bar"],
           [85, 663, "Belpstrasse 37"],
           [85, 653, "8001 Zürich"],
           [420, 517, "Bern, 17. Mai 2022"],
           [57, 495, "Hallo"],
           [57, 474, "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! "],
           [57, 454, "Bis bald"],
           [14, 276, "Empfangsschein"],
           [14, 251, "Konto / Zahlbar an"],
           [14, 239, "CH93 0030 0111 6238 5295 7"],
           [14, 228, "Puzzle ITC"],
           [14, 216, "Belpstrasse 37"],
           [14, 205, "3007 Bern"],
           [14, 173, "Zahlbar durch"],
           [14, 161, "Alice Bar"],
           [14, 150, "Belpstrasse 37"],
           [14, 138, "8001 Zürich"],
           [14, 89, "Währung"],
           [71, 89, "Betrag"],
           [14, 78, "CHF"],
           [71, 78, "150.00"],
           [105, 39, "Annahmestelle"],
           [190, 276, "Zahlteil"],
           [190, 89, "Währung"],
           [247, 89, "Betrag"],
           [190, 78, "CHF"],
           [247, 78, "150.00"],
           [346, 278, "Konto / Zahlbar an"],
           [346, 266, "CH93 0030 0111 6238 5295 7"],
           [346, 255, "Puzzle ITC"],
           [346, 243, "Belpstrasse 37"],
           [346, 232, "3007 Bern"],
           [346, 211, "Referenznummer"],
           [346, 200, "00 00542 00303 80000 00000 00019"],
           [346, 178, "Zahlbar durch"],
           [346, 167, "Alice Bar"],
           [346, 155, "Belpstrasse 37"],
           [346, 144, "8001 Zürich"]]

        expect(text_with_position).to eq(expected_content)
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
