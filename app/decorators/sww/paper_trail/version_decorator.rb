# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::PaperTrail
  module VersionDecorator
    def author_service_token_label(token)
      return super if specific_author.blank?

      "#{specific_author.inspect} via #{ServiceToken.model_name.human}: #{token}"
    end
  end
end
