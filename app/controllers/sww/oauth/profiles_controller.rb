# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Oauth::ProfilesController
  extend ActiveSupport::Concern

  def scope_attrs
    super&.merge(sww_cms_profile_id: person.sww_cms_profile_id)
  end
end
