# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::VariousAbility
  RESTRICTED_GROUPS = [
    Group::Mitglieder,
    Group::Kontakte
  ].freeze

  def everybody_unless_only_basic_permissions_roles
    super && !user.roles.all? { RESTRICTED_GROUPS.include?(_1.group.class) }
  end
end
