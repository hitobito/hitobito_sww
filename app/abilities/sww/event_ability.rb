# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

module Sww::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event) do
      # permission(:group_and_below_full).may(:index_participations, :show)
      #   .in_same_group_or_below
      # permission(:group_and_below_full).may(:index_invitations)
      #   .in_same_group_or_below_and_invitations_supported
      permission(:group_and_below_full).may(:create, :update, :destroy, :manage_tags, :application_market)
        .in_same_group_or_below_if_active
    end
  end
end
