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

      it 'renders membership card in addition to letter' do
        expect(text_with_position).to eq([[346, 711, "Mitgliederausweis"],
                                          [346, 693, "Alice Bar"],
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

  private

  def text_with_position
    analyzer.positions.each_with_index.collect do |p, i|
      p.collect(&:round) + [analyzer.show_text[i]]
    end
  end
end
