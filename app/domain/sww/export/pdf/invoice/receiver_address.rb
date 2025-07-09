# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice::ReceiverAddress
  private

  def receiver_address_data
    @receiver_address_data ||= super.tap do |addr|
      addr.unshift([invoice.recipient&.sww_salutation]) if invoice.recipient&.gender.present?
    end
  end

  def group
    invoice.group
  end
end
