# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Event::ParticipationAbility do
  let(:user) { people(:no_permissions) }
  let(:kind) { Fabricate(:event_kind) }
  let(:course) { Fabricate(:course, groups: [groups(:berner_wanderwege)], kind: kind) }
  let(:participation) { Fabricate(:event_participation, event: course, participant: user) }
  let(:other_participation) { Fabricate(:event_participation, event: course) }
  let(:new_participation) { Event::Participation.new(event: course, person: Fabricate(:person)) }

  subject(:ability) { Ability.new(user.reload) }

  context "with_event_role for someone else" do
    context "with permission :participations_full" do
      let!(:leader_role) {
        Fabricate(Event::Role::ParticipationsFull.name, participation: participation)
      }

      it { is_expected.to be_able_to :show, other_participation }
      it { is_expected.to be_able_to :show_details, other_participation }
      it { is_expected.to be_able_to :show_full, other_participation }
      it { is_expected.to be_able_to :create, new_participation }
      it { is_expected.to be_able_to :update, other_participation }
    end

    context "with regular participant role" do
      let!(:participant_role) {
        Fabricate(Event::Course::Role::Participant.name, participation: participation)
      }

      it { is_expected.not_to be_able_to :show, other_participation }
      it { is_expected.not_to be_able_to :show_details, other_participation }
      it { is_expected.not_to be_able_to :show_full, other_participation }
      it { is_expected.not_to be_able_to :create, new_participation }
      it { is_expected.not_to be_able_to :update, other_participation }
    end
  end
end
