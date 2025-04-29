# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Event::ParticipationMailer do
  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join("db", "seeds")]
  end

  let(:person) { people(:berner_wanderer) }
  let(:event) { Fabricate(:event, groups: [group]) }
  let(:participation) { Fabricate(:event_participation, event: event, person: person) }

  let(:group) { groups(:berner_mitglieder) }
  let(:layer) { groups(:berner_wanderwege) }

  describe "#confirmation" do
    let(:mail) { Event::ParticipationMailer.confirmation(participation) }

    context "with event sender defined on layer" do
      before { layer.update!(event_sender: "Berner Wanderwege") }

      it "renders layer event sender" do
        expect(mail[:from].value).to eq("Berner Wanderwege <noreply@localhost>")
        expect(mail.from).to eq(["noreply@localhost"])
      end

      context "with event sender defined on group" do
        before { group.update!(event_sender: "Berner Mitglieder") }

        it "renders group event sender" do
          expect(mail[:from].value).to eq("Berner Mitglieder <noreply@localhost>")
          expect(mail.from).to eq(["noreply@localhost"])
        end
      end
    end

    it "renders default sender without event sender defined" do
      expect(mail[:from].value).to eq("Schweizer Wanderwege - Suisse Rando <noreply@localhost>")
      expect(mail.from).to eq(["noreply@localhost"])
    end
  end

  describe "#notify_contact" do
    let(:recipient) { Fabricate(:person) }
    let(:mail) { Event::ParticipationMailer.notify_contact(participation, recipient) }

    context "with event sender defined on layer" do
      before { layer.update!(event_sender: "Berner Wanderwege") }

      it "renders layer event sender" do
        expect(mail[:from].value).to eq("Berner Wanderwege <noreply@localhost>")
        expect(mail.from).to eq(["noreply@localhost"])
      end

      context "with event sender defined on group" do
        before { group.update!(event_sender: "Berner Mitglieder") }

        it "renders group event sender" do
          expect(mail[:from].value).to eq("Berner Mitglieder <noreply@localhost>")
          expect(mail.from).to eq(["noreply@localhost"])
        end
      end
    end

    it "renders default sender without event sender defined" do
      expect(mail[:from].value).to eq("Schweizer Wanderwege - Suisse Rando <noreply@localhost>")
      expect(mail.from).to eq(["noreply@localhost"])
    end
  end

  describe "#approval" do
    let(:approvers) do
      [Fabricate(:person, email: "approver0@example.com", first_name: "firsty"),
        Fabricate(:person, email: "approver1@example.com", first_name: "lasty")]
    end
    let(:mail) { Event::ParticipationMailer.approval(participation, approvers) }

    context "with event sender defined on layer" do
      before { layer.update!(event_sender: "Berner Wanderwege") }

      it "renders layer event sender" do
        expect(mail[:from].value).to eq("Berner Wanderwege <noreply@localhost>")
        expect(mail.from).to eq(["noreply@localhost"])
      end

      context "with event sender defined on group" do
        before { group.update!(event_sender: "Berner Mitglieder") }

        it "renders group event sender" do
          expect(mail[:from].value).to eq("Berner Mitglieder <noreply@localhost>")
          expect(mail.from).to eq(["noreply@localhost"])
        end
      end
    end

    it "renders default sender without event sender defined" do
      expect(mail[:from].value).to eq("Schweizer Wanderwege - Suisse Rando <noreply@localhost>")
      expect(mail.from).to eq(["noreply@localhost"])
    end
  end

  describe "#cancel" do
    let(:mail) { Event::ParticipationMailer.cancel(event, person) }

    context "with event sender defined on layer" do
      before { layer.update!(event_sender: "Berner Wanderwege") }

      it "renders layer event sender" do
        expect(mail[:from].value).to eq("Berner Wanderwege <noreply@localhost>")
        expect(mail.from).to eq(["noreply@localhost"])
      end

      context "with event sender defined on group" do
        before { group.update!(event_sender: "Berner Mitglieder") }

        it "renders group event sender" do
          expect(mail[:from].value).to eq("Berner Mitglieder <noreply@localhost>")
          expect(mail.from).to eq(["noreply@localhost"])
        end
      end
    end

    it "renders default sender without event sender defined" do
      expect(mail[:from].value).to eq("Schweizer Wanderwege - Suisse Rando <noreply@localhost>")
      expect(mail.from).to eq(["noreply@localhost"])
    end
  end
end
