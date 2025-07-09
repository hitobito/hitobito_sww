# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
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

      it 'renders membership card onto the letter' do
        expect(text_with_position).to include(
          [346, 721, "Mitgliederausweis"],
          [346, 710, "42431"],
          [346, 699, "Alice Bar"],
          [511, 721, "Gültig bis"],
          [517, 710, "12.2042"]
        )
      end


      it 'renders the letter' do
        text = text_with_position.map { |x, y, text| text }
        expect(text).to include(
          "P.P.  | POST CH AG",
          "Alice Bar",
          "Belpstrasse 37",
          "8001 Zürich",
          "Bern, 17. Mai 2022",
          "MITGLIEDERAUSWEIS 2022 WANDERN.CH",
          "Hallo",
          "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! ",
          "Bis bald"
        )
      end

      it 'moves the address to the right' do
        address = text_with_position.find { |_, _, text| text == 'Belpstrasse 37' }
        expect(address[0]).to eql 57
      end

      it 'leaves the date in place' do
        date = text_with_position.find { |_, _, text| text.starts_with?('Bern,') }
        expect(date[0]).to eql 420
        expect(date[1]).to eql 516
      end

      it 'leaves the body in place' do
        body = text_with_position.find { |_, _, text| text == 'Hallo' }
        expect(body[0]).to eql 57
        expect(body[1]).to eql 460
      end
    end

    context 'rendered right' do
      before do
        letter.group.letter_address_position = :right
        letter.group.save!
      end

      it 'renders membership card onto the letter' do
        expect(text_with_position).to include(
          [57, 721, "Mitgliederausweis"],
          [57, 710, "42431"],
          [57, 699, "Alice Bar"],
          [222, 721, "Gültig bis"],
          [227, 710, "12.2042"]
        )
      end

      it 'renders the letter' do
        text = text_with_position.map { |x, y, text| text }
        expect(text).to include(
          "P.P.  | POST CH AG",
          "Alice Bar",
          "Belpstrasse 37",
          "8001 Zürich",
          "Bern, 17. Mai 2022",
          "MITGLIEDERAUSWEIS 2022 WANDERN.CH",
          "Hallo",
          "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! ",
          "Bis bald"
        )
      end

      it 'moves the address to the left' do
        address = text_with_position.find { |_, _, text| text == 'Belpstrasse 37' }
        expect(address[0]).to eql 347
      end

      it 'leaves the date in place' do
        date = text_with_position.find { |_, _, text| text.starts_with?('Bern,') }
        expect(date[0]).to eql 420
        expect(date[1]).to eql 516
      end

      it 'leaves the body in place' do
        body = text_with_position.find { |_, _, text| text == 'Hallo' }
        expect(body[0]).to eql 57
        expect(body[1]).to eql 460
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

      it 'renders membership card onto the letter' do
        expect(text_with_position).to include(
          [283, 693, "Mitgliederausweis"],
          [283, 681, "42431"],
          [283, 670, "Alice Bar"],
          [449, 693, "Gültig bis"],
          [454, 681, "12.2042"]
        )
      end

      it 'renders the letter' do
        text = text_with_position.map { |x, y, text| text }
        expect(text).to include(
          "P.P.  | POST CH AG",
          "Alice Bar",
          "Belpstrasse 37",
          "8001 Zürich",
          "Bern, 17. Mai 2022",
          "MITGLIEDERAUSWEIS 2022 WANDERN.CH",
          "Hallo",
          "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! ",
          "Bis bald"
        )
      end

      it 'moves the address a good position' do
        address = text_with_position.find { |_, _, text| text == 'Belpstrasse 37' }
        expect(address[0]).to eql 85
      end

      it 'leaves the date in place' do
        date = text_with_position.find { |_, _, text| text.starts_with?('Bern,') }
        expect(date[0]).to eql 420
        expect(date[1]).to eql 516
      end

      it 'leaves the body in place' do
        body = text_with_position.find { |_, _, text| text == 'Hallo' }
        expect(body[0]).to eql 57
        expect(body[1]).to eql 460
      end
    end

    context 'name length' do
      it 'long name renders on lone line' do
        people(:zuercher_wanderer).update(
          first_name: "Michelangelo",
          last_name: "Greiner-Petter-Memm"
        )

        expect(text_with_position).to include(
          [346, 721, "Mitgliederausweis"],
          [346, 710, "42431"],
          [346, 699, "Michelangelo Greiner-Petter-Memm"],
          [511, 721, "Gültig bis"]
        )
      end

      it 'extreme long name renders on two lines' do
        people(:zuercher_wanderer).update(
          first_name: "Captain Fantastic",
          last_name: "Faster Than Superman Spiderman Batman Wolverine Hulk And The Flash Combined",
        )

        expect(text_with_position).to include(
          [346, 721, "Mitgliederausweis"],
          [346, 710, "42431"],
          [346, 700, "Captain Fantastic Faster Than Superman Spiderman"],
          [346, 691, "Batman Wolverine Hulk And The Flash Combined"],
          [511, 721, "Gültig bis"]
        )
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
