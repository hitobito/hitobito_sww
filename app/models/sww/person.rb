# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :member_number << :custom_salutation << :magazin_abo_number
    Person::INTERNAL_ATTRS << :alabus_id << :member_number
  end

end
