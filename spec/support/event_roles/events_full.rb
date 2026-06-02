# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class Event::Role::EventsFull < Event::Role
  self.permissions = [:participations_full]

  self.kind = :leader
end

Event.role_types << Event::Role::EventsFull
