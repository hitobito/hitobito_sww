# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Event::ParticipationAbility do
  subject(:ability) { Ability.new(user.reload) }

  context :layer_and_below_full do
    let(:user) { role.person }
    let(:group) { groups(:schweizer_wanderwege) }
    let(:event) { Fabricate(:event, groups: [group], globally_visible: false) }
    let(:participation) { Fabricate(:event_participation, event: event) }
    let(:role) { Fabricate(Group::SchweizerWanderwege::Support.name.to_sym, group: group) }

    context "on Event::Participation" do
      it "may create participation in his layer" do
        is_expected.to be_able_to(:create, participation)
      end

      it "may destroy participation in his layer" do
        is_expected.to be_able_to(:destroy, participation)
      end
    end

    context "on Event::Participation in subgroup (Fachorganisation)" do
      let(:subgroup) { groups(:berner_wanderwege) }
      let(:event_in_subgroup) { Fabricate(:event, groups: [subgroup], globally_visible: false) }
      let(:participation_in_subgroup) { Fabricate(:event_participation, event: event_in_subgroup) }

      it "may create participation in subgroup" do
        is_expected.to be_able_to(:create, participation_in_subgroup)
      end

      it "may destroy participation in subgroup" do
        is_expected.to be_able_to(:destroy, participation_in_subgroup)
      end
    end
  end

  context "with_event_role for someone else" do
    let(:user) { people(:no_permissions) }
    let(:kind) { Fabricate(:event_kind) }
    let(:course) { Fabricate(:course, groups: [groups(:berner_wanderwege)], kind: kind) }
    let(:participation) { Fabricate(:event_participation, event: course, participant: user) }
    let(:other_participation) { Fabricate(:event_participation, event: course) }
    let(:new_participation) { Event::Participation.new(event: course, person: Fabricate(:person)) }

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
