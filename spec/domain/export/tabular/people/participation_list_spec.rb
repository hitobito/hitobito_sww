# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Wanderwege. This file is part of
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
        expect(attribute_labels[:"question_#{question.id}"]).to eq("Vegi?")
      end
    end
  end

  describe "data_rows" do
    let(:guest) { Fabricate(:event_guest, phone_number: "+41 79 765 43 21") }
    let(:guest_participation) { Fabricate(:event_participation, participant: guest, event:) }
    let(:export) { described_class.new([guest_participation], ability) }

    it "contains phone number of guest as mobile number" do
      row = export.data_rows.first

      expect(row[export.attributes.index(:phone_mobile)]).to eq "+41 79 765 43 21"
    end
  end
end
