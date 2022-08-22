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
          letter.group.settings(:messages_letter).address_position = :left
          letter.group.save!
        end

        it 'renders membership card in addition to letter' do
          expect(text_with_position).to eq([[346, 721, "Mitgliederausweis"],
                                            [346, 698, "Alice Bar"],
                                            [511, 710, "Gültig bis"],
                                            [517, 698, "12.2042"],
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
          letter.group.settings(:messages_letter).address_position = :right
          letter.group.save!
        end

        it 'renders membership card in addition to letter' do
          expect(text_with_position).to eq([[57, 721, "Mitgliederausweis"],
                                            [57, 698, "Alice Bar"],
                                            [222, 710, "Gültig bis"],
                                            [227, 698, "12.2042"],
                                            [346, 704, "P.P.  | POST CH AG"],
                                            [346, 682, "Alice Bar"],
                                            [346, 672, "Belpstrasse 37"],
                                            [346, 662, "8001 Zürich"],
                                            [420, 517, "Bern, 17. Mai 2022"],
                                            [57, 491, "MITGLIEDERAUSWEIS 2022 WANDERN.CH"],
                                            [57, 463, "Hallo"],
                                            [57, 442, "Gerne stellen wir Ihnen Ihren Mitgliederausweis zu! "],
                                            [57, 422, "Bis bald"]])
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
