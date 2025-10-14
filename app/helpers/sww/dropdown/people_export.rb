# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww
  # It's safe to use instance variables here because they
  # are encapsulated within their own class.
  # rubocop:disable Rails/HelperInstanceVariable
  module Dropdown
    module PeopleExport
      def tabular_links(format)
        super.tap do |item|
          if @details && params[:controller] == "event/participations"
            path = params.merge(format: format)

            item.sub_items << ::Dropdown::Item.new(translate(:participations),
              path.merge(participations_list: true))
          end
        end
      end
    end
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
