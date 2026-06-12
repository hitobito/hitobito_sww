# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Event::ParticipationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Participation) do
      for_self_or_manageds do
        permission(:any).may(:create).her_own_or_for_participations_full_events
      end
    end
  end

  def her_own_or_for_participations_full_events
    her_own_if_application_possible || for_participations_full_events
  end
end
