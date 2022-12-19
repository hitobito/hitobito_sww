# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Group::SchweizerWanderwege < ::Group

  self.layer = true

  children Group::Benutzerkonten,
           Group::Kontakte,
           Group::Fachorganisation

  ### ROLES

  class Mitarbeitende < ::Role
    self.permissions = [:layer_and_below_full]
  end

  class Support < ::Role
    self.permissions = [:layer_and_below_full, :admin, :finance, :impersonation]
  end

  roles Mitarbeitende, Support

end
