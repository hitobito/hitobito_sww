# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Event::ParticipationAbility do
  let(:user) { role.person }
  let(:group) { groups(:schweizer_wanderwege) }
  let(:event) { Fabricate(:event, groups: [group], globally_visible: false) }
  let(:participation) { Fabricate(:event_participation, event: event) }

  subject(:ability) { Ability.new(user.reload) }

  context :layer_and_below_full do
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
end
