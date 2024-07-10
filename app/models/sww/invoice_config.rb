# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::InvoiceConfig
  extend ActiveSupport::Concern

  LOGO_POSITION_ABOVE_PAYMENT_SLIP = "above_payment_slip"

  prepended do
    logo_positions << LOGO_POSITION_ABOVE_PAYMENT_SLIP
  end
end
