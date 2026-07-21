# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Export::Tabular::People::ParticipationsList do
  let(:event) { participation.event }
  let(:participation) { event_participations(:top_leader) }
  let(:ability) { Ability.new(participation.person) }

  subject(:attribute_labels) { described_class.new([participation], ability).attribute_labels }

  describe "attribute_labels" do
    it "contains keys and translated labels" do
      expect(attribute_labels).to include(
        {
          first_name: "Vorname",
          last_name: "Nachname",
          email: "E-Mail",
          full_address: "Adresse",
          phone_mobile: "Telefonnummer (Mobil)",
          participation_additional_information: "Bemerkungen"
        }
      )
    end

    context "event with question" do
      it "contains questions" do
        question = Fabricate(:event_question, event: event, question: "Vegi?")
        expect(question.event).to eq participation.event
        participation.answers.find_by(question:).update!(answer: "Ja")
        expect(attribute_labels[:"question_#{question.id}"]).to eq("Vegi?")
      end
    end
  end
end
