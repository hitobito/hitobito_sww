# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Group::Geschaeftsstelle < ::Group
  ### ROLES

  class Geschaeftsfuehrer < ::Role
    self.permissions = [:contact_data, :layer_and_below_full, :finance]
  end

  class Kassier < ::Role
    self.permissions = [:finance, :layer_and_below_full]
  end

  class TechnischerLeiter < ::Role
    self.permissions = [:layer_and_below_full]
  end

  class Mitarbeiter < ::Role
    self.permissions = [:layer_and_below_full]
  end

  roles Geschaeftsfuehrer, Kassier, TechnischerLeiter, Mitarbeiter
end
