# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Group::Benutzerkonten < ::Group
  self.layer = true

  ### ROLES

  class Verwalter < ::Role
    self.permissions = [:layer_full]
  end

  class Benutzerkonto < ::Role
    self.visible_from_above = false
    self.basic_permissions_only = true

    self.permissions = []
  end

  roles Benutzerkonto, Verwalter
end
