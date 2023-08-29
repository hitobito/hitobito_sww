# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::Export::Pdf::Invoice::ReceiverAddress

  def render
    float do
      offset_cursor_from_top 5.1.cm
      bounding_box(address_position(invoice.group), width: bounds.width, height: 80) do
        receiver_address_data.unshift([invoice.recipient&.sww_salutation]) if invoice.recipient&.gender.present?
        table(receiver_address_data, cell_style: { borders: [], padding: [0, 0, 0, 0] })
      end
    end
  end

end
