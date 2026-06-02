# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Event::InvitationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Invitation) do
      permission(:any)
        .may(:create, :destroy)
        .for_participations_full_events_and_invitations_supported
    end
  end

  def for_participations_full_events_and_invitations_supported
    for_participations_full_events && invitations_supported?
  end
end
