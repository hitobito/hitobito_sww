# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Export::Pdf::Messages::Letter do
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

    let (:recipient) { people(:top_leader) }

    context 'with letter' do
      subject { Export::Pdf::Messages::Letter.new(letter, options) }

      before do
        Messages::LetterDispatch.new(letter).run
      end

      let(:letter) { messages(:membership_card_letter) }

      it 'renders membership card in addition to letter' do
        expect(text_with_position).to eq([[180, 685, "Post CH AG"],
                                          [71, 672, "P.P."],
                                          [91, 672, ""],
                                          [71, 654, "Alice Bar"],
                                          [71, 644, "Belpstrasse 37"],
                                          [71, 633, "8001 Zürich"],
                                          [71, 559, "Bern, 17. Mai 2022"],
                                          [71, 531, "Leserkarte 2022 WANDERN.CH"],
                                          [71, 502, "Hallo"],
                                          [71, 482, "Gerne stellen wir Ihnen Ihre Leserkarte zu! "],
                                          [71, 461, "Bis bald"]])

      end
    end

    context 'with invoice letter' do
      subject { Export::Pdf::Messages::LetterWithInvoice.new(letter, options) }

      let(:letter) do
        letter_attrs = messages(:membership_card_letter).attributes.except('type', 'id')
        attrs = letter_attrs.merge(body: messages(:membership_card_letter).body,
                                   invoice_attributes: {
                                     invoice_items_attributes: [{
                                       name: 'Mitgliederbeitrag',
                                       unit_cost: 150,
                                       amount: 1
                                     }]
                                   })

        l = Message::LetterWithInvoice.create!(attrs)

        InvoiceConfig.create!(group: l.group,
                              sequence_number: 1, 
                              address: "Puzzle\nBelpstrasse 37\n3007 Bern",
                              iban: 'CH93 0030 0111 6238 5295 7',
                              account_number: '10-5318-5',
                              payment_slip: 'qr',
                              payee: 'Puzzle ITC'
                             )

        l
      end

      before do
        Messages::LetterWithInvoiceDispatch.new(letter).run
      end

      it 'renders membership card in addition to letter' do
        expect(text_with_position).to eq([[180, 685, "Post CH AG"],
                                          [71, 672, "P.P."],
                                          [91, 672, ""],
                                          [71, 654, "Alice Bar"],
                                          [71, 644, "Belpstrasse 37"],
                                          [71, 633, "8001 Zürich"],
                                          [71, 559, "Bern, 17. Mai 2022"],
                                          [71, 531, "Leserkarte 2022 WANDERN.CH"],
                                          [71, 502, "Hallo"],
                                          [71, 482, "Gerne stellen wir Ihnen Ihre Leserkarte zu! "],
                                          [71, 461, "Bis bald"],
                                          [28, 290, "Empfangsschein"],
                                          [28, 265, "Konto / Zahlbar an"],
                                          [28, 254, "CH93 0030 0111 6238 5295 7"],
                                          [28, 242, "Puzzle ITC"],
                                          [28, 187, "Zahlbar durch"],
                                          [28, 175, "Alice Bar"],
                                          [28, 164, "Belpstrasse 37"],
                                          [28, 152, "8001 Zürich"],
                                          [28, 103, "Währung"],
                                          [85, 103, "Betrag"],
                                          [28, 92, "CHF"],
                                          [119, 53, "Annahmestelle"],
                                          [204, 290, "Zahlteil"],
                                          [204, 103, "Währung"],
                                          [261, 103, "Betrag"],
                                          [204, 92, "CHF"],
                                          [360, 292, "Konto / Zahlbar an"],
                                          [360, 280, "CH93 0030 0111 6238 5295 7"],
                                          [360, 269, "Puzzle ITC"],
                                          [360, 225, "Referenznummer"],
                                          [360, 214, "00 00542 00303 80000 00000 00019"],
                                          [360, 193, "Zahlbar durch"],
                                          [360, 181, "Alice Bar"],
                                          [360, 170, "Belpstrasse 37"],
                                          [360, 158, "8001 Zürich"]])

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
