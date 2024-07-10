# frozen_string_literal: true

#  Copyright (c) `2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::MailingListAbility
  extend ActiveSupport::Concern

  included do
    on(::MailingList) do
      permission(:support).may(:manage).all
    end
  end
end
