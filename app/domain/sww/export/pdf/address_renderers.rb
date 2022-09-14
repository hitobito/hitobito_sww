# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

module Sww::Export::Pdf::AddressRenderers
  include ActiveSupport::Concern

  included do
    def address_position(group)
      [group.settings(:messages_letter).left_address_offset.cm,
       group.settings(:messages_letter).top_address_offset.cm]
    end
  end
end
