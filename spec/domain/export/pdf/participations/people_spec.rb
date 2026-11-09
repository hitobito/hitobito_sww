# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Export::Pdf::Participations::People do
  include PdfHelpers

  let(:participation) {
    Fabricate(:event_participation, additional_information: "Ich mag kein Gemüse!!!",
      participant: person)
  }
  let(:person) { people(:berner_wanderer) }
  let(:group) { groups(:schweizer_wanderwege) }
  let(:contactables) { [top_leader.tap { |u| u.update(nickname: "Funny Name") }] }
  let(:pdf) {
    Export::Pdf::Participations::Runner.new.render([participation], group, participation.event)
  }

  subject { PDF::Inspector::Text.analyze(pdf) }

  before do
    Fabricate(Event::Role::Leader.sti_name, participation: participation)
    Fabricate(Event::Role::Cook.sti_name, participation: participation)
  end

  it "renders event name as title" do
    expect(subject.show_text).to include "Eventus"
  end

  it "renders pdf list with comments and event roles" do
    pdf_text = [
      [28, 546, "Eventus"],
      [28, 515, "Name"],
      [68, 515, "Adresse"],
      [182, 515, "E-Mail"],
      [269, 515, "Privat"],
      [301, 515, "Mobil"],
      [331, 515, "Bemerkungen"],
      [435, 515, "Anlass Rollen"],
      [28, 501, "Foo Bob"],
      [68, 501, "Belpstrasse 37, 3007 Bern"],
      [182, 501, "bob@example.com"],
      [331, 501, "Ich mag kein Gemüse!!!"],
      [435, 501, "Hauptleitung, Küche"],
      [760, 19, "Seite 1 von 1"]
    ]

    pdf_text.each_with_index do |text, i|
      expect(text_with_position[i]).to eq(text)
    end
  end

  context "with phone numbers" do
    before do
      Fabricate(:phone_number, contactable: person, number: "+41 31 111 11 11",
        category: contact_account_categories(:phone_number_person_landline))
      Fabricate(:phone_number, contactable: person, number: "+41 79 222 22 22",
        category: contact_account_categories(:phone_number_person_mobile))
    end

    def x_position(text)
      text_with_position.find { |_x, _y, t| t == text }&.first
    end

    it "lists the numbers in the columns Privat and Mobil" do
      expect(x_position("+41 31 111 11 11")).to eq x_position("Privat")
      expect(x_position("+41 79 222 22 22")).to eq x_position("Mobil")
    end
  end
end
