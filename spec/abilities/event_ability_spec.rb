# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require "spec_helper"

describe EventAbility do
  let(:user) { role.person }
  let(:group) { groups(:berner_gremium) }
  let(:event) { Fabricate(:event, groups: [group], globally_visible: false) }

  subject(:ability) { Ability.new(user.reload) }

  context :layer_and_below_full do
    let(:role) { Fabricate(Group::GremiumProjektgruppe::Leitung.name.to_sym, group: group) }

    context "on Event" do
      it "may create events (as with the core-ability)" do
        is_expected.to be_able_to(:create, event)
      end

      it "may edit events (as with the core-ability)" do
        is_expected.to be_able_to(:update, event)
      end

      it "may delete events (as with the core-ability)" do
        is_expected.to be_able_to(:destroy, event)
      end

      it "may see application market for event in his layer" do
        is_expected.to be_able_to(:application_market, event)
      end
    end
  end
end
