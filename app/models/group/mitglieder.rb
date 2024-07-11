# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Group::Mitglieder < ::Group
  children Group::Mitglieder

  ### ROLES

  class Aktivmitglied < ::Role
    self.permissions = []
  end

  class Passivmitglied < ::Role
    self.permissions = []
  end

  class Freimitglied < ::Role
    self.permissions = []
  end

  class Organisationen < ::Role
    self.permissions = []
  end

  class Partner < ::Role
    self.permissions = []
  end

  class Spender < ::Role
    self.permissions = []
  end

  class MagazinAbonnent < ::Role
    self.permissions = []
  end

  roles Aktivmitglied, Passivmitglied, Freimitglied, Organisationen,
    Partner, Spender, MagazinAbonnent
end
