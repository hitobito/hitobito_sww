# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::JsonApiController
  extend ActiveSupport::Concern

  DONMAN_USER_ATTRIBUTE = :donman_update_by

  def info_for_paper_trail
    super.merge(
      specific_author: donman_update_by
    )
  end

  private

  def donman_update_by
    params[DONMAN_USER_ATTRIBUTE].presence if current_service_token
  end
end
