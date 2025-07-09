# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Group::Vorstand < ::Group
  ### ROLES

  class Praesident < ::Role
    self.permissions = [:contact_data, :layer_and_below_full]
  end

  class Vizepraesident < ::Role
    self.permissions = [:contact_data, :layer_and_below_full]
  end

  class Vorstandsmitglied < ::Role
    self.permissions = [:layer_and_below_full]
  end

  roles Praesident, Vizepraesident, Vorstandsmitglied
end
