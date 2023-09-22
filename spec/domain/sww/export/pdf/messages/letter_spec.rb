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

    subject { Export::Pdf::Messages::Letter.new(letter, options) }

    before do
      Messages::LetterDispatch.new(letter).run
    end

    let(:letter) { messages(:membership_card_letter) }

    context 'rendered left' do
      before do
        letter.group.letter_address_position = :left
        letter.group.save!
      end

      it 'renders membership card in addition to letter' do
        expect(text_with_position).to eq([[346, 721, "Mitgliederausweis"],
                                          [346, 710, "42431"],
                                          [346, 699, "Alice Bar"],
                                          [511, 721, "Gültig bis"],
                                          [517, 710, "12.2042"],
                                          [57, 704, "P.P.  | POST CH AG"],
                                          [57, 682, "Alice Bar"],
                                          [57, 672, "Belpstrasse 37"],
                                          [57, 662, "8001 Zürich"],
                                          [420, 517, "Bern, 17. Mai 2022"],
                                          [57, 491, "MITGLIEDERAUSWEIS 2022 WANDERN.CH"],
                                          [57, 463, "Hallo"],
                                          [57, 442, "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! "],
                                          [57, 422, "Bis bald"]])
      end
    end

    context 'rendered right' do
      before do
        letter.group.letter_address_position = :right
        letter.group.save!
      end

      it 'renders membership card in addition to letter' do
        expect(text_with_position).to eq([[57, 721, "Mitgliederausweis"],
                                          [57, 710, "42431"],
                                          [57, 699, "Alice Bar"],
                                          [222, 721, "Gültig bis"],
                                          [227, 710, "12.2042"],
                                          [347, 704, "P.P.  | POST CH AG"],
                                          [347, 682, "Alice Bar"],
                                          [347, 672, "Belpstrasse 37"],
                                          [347, 662, "8001 Zürich"],
                                          [420, 517, "Bern, 17. Mai 2022"],
                                          [57, 491, "MITGLIEDERAUSWEIS 2022 WANDERN.CH"],
                                          [57, 463, "Hallo"],
                                          [57, 442, "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! "],
                                          [57, 422, "Bis bald"]])
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

      it 'renders membership card in addition to letter' do
        expect(text_with_position).to eq([[283, 693, "Mitgliederausweis"],
                                          [283, 681, "42431"],
                                          [283, 670, "Alice Bar"],
                                          [449, 693, "Gültig bis"],
                                          [454, 681, "12.2042"],
                                          [85, 695, "P.P.  | POST CH AG"],
                                          [85, 674, "Alice Bar"],
                                          [85, 663, "Belpstrasse 37"],
                                          [85, 653, "8001 Zürich"],
                                          [420, 517, "Bern, 17. Mai 2022"],
                                          [57, 491, "MITGLIEDERAUSWEIS 2022 WANDERN.CH"],
                                          [57, 463, "Hallo"],
                                          [57, 442, "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! "],
                                          [57, 422, "Bis bald"]])
      end
    end

    context 'name length' do
      it 'long name renders on lone line' do
        people(:zuercher_wanderer).update(
          first_name: "Michelangelo",
          last_name: "Greiner-Petter-Memm"
        )

        expect(text_with_position.take(4)).to eq([[346, 721, "Mitgliederausweis"],
                                                  [346, 710, "42431"],
                                                  [346, 699, "Michelangelo Greiner-Petter-Memm"],
                                                  [511, 721, "Gültig bis"]])
      end

      it 'extreme long name renders on two lines' do
        people(:zuercher_wanderer).update(
          first_name: "Captain Fantastic",
          last_name: "Faster Than Superman Spiderman Batman Wolverine Hulk And The Flash Combined",
        )

        expect(text_with_position.take(5)).to eq([[346, 721, "Mitgliederausweis"],
                                                  [346, 710, "42431"],
                                                  [346, 700, "Captain Fantastic Faster Than Superman Spiderman"],
                                                  [346, 691, "Batman Wolverine Hulk And The Flash Combined"],
                                                  [511, 721, "Gültig bis"]])
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
