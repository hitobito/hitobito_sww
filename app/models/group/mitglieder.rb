# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Group::Mitglieder < ::Group
  children Group::Mitglieder

  mounted_attr :droptours_export, :boolean

  ### ROLES

  class Aktivmitglied < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Freimitglied < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Organisationen < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Partner < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Spender < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class MagazinAbonnent < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  roles Aktivmitglied, Passivmitglied, Freimitglied, Organisationen,
    Partner, Spender, MagazinAbonnent
end
