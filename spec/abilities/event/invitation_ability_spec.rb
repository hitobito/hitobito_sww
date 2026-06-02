# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Event::InvitationAbility do
  let(:user) { people(:no_permissions) }
  let(:event_kind) { Fabricate(:event_kind) }
  let(:course) { Fabricate(:course, groups: [groups(:berner_wanderwege)], kind: event_kind) }
  let(:invitee) { Fabricate(:person) }
  let(:invitation) { Fabricate(:event_invitation, event: course, person: invitee) }
  let(:participation) { Fabricate(:event_participation, event: course, participant: user) }
  let(:other_course) { Fabricate(:course, groups: [groups(:berner_wanderwege)], kind: event_kind) }
  let(:other_invitation) { Fabricate(:event_invitation, event: other_course, person: invitee) }

  subject(:ability) { Ability.new(user) }

  context "with event role" do
    context "with permission participations_full" do
      let!(:participations_full_role) {
        Fabricate(Event::Role::ParticipationsFull.name, participation: participation)
      }

      context "for own event" do
        it { is_expected.to be_able_to :create, invitation }
        it { is_expected.to be_able_to :destroy, invitation }
      end

      context "for other event" do
        it { is_expected.not_to be_able_to :create, other_invitation }
        it { is_expected.not_to be_able_to :destroy, other_invitation }
      end
    end

    context "regular participant" do
      let!(:participant_role) {
        Fabricate(Event::Course::Role::Participant.name, participation: participation)
      }

      context "for own event" do
        it { is_expected.not_to be_able_to :create, invitation }
        it { is_expected.not_to be_able_to :destroy, invitation }
      end

      context "for other event" do
        it { is_expected.not_to be_able_to :create, other_invitation }
        it { is_expected.not_to be_able_to :destroy, other_invitation }
      end
    end
  end
end
