#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::LayoutHelper
  def render_nav?
    super && !(current_user.roles.present? && current_user.roles.all?(Group::Benutzerkonten::Benutzerkonto))
  end
end
