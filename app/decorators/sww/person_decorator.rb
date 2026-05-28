# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Sww::PersonDecorator
  def created_info
    return nil if current_user&.basic_permissions_only?
    super
  end

  def updated_info
    return nil if current_user&.basic_permissions_only?
    super
  end
end
