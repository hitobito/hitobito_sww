# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Export::Tabular::People::ParticipationsList do
  let(:event) { events(:top_course) }
  let(:participation) { event_participations(:top_participant) }

  describe "attribute_labels" do
    it "contains keys and translated labels" do
      attribute_labels = described_class.new([participation]).attribute_labels

      expect(attribute_labels).to eq(
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
      let(:question) {
        Fabricate(:event_question, event: event, question: "Vegi?")
      }

      it "contains questions" do
        participation.answers.create! question: question, answer: "Ja"

        attribute_labels = described_class.new([participation]).attribute_labels

        expect(attribute_labels[:"question_#{question.id}"]).to eq("Vegi?")
      end
    end
  end
end
