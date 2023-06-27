# frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Tabular::People::PeopleFull
  extend ActiveSupport::Concern

  prepended do
    self.row_class = Sww::Export::Tabular::People::PersonFullRow
  end

  def person_attributes
    super + [:id, :sww_salutation]
  end
end
