# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# TODO: remove method after core branch `feature/json-api-finis` is merged
module Sww::JsonApi::PeopleController
  def index_people_scope
    super.select(:updated_at, :updater_id)
  end
end
