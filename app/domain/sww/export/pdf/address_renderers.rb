# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

module Sww::Export::Pdf::AddressRenderers
  extend ActiveSupport::Concern

  included do
    def address_position(group)
      left = left_offset(group)
      x_coords = left.to_f.cm - page.margins[:left] if left.present?

      x_coords ||= {
        left: self.class::LEFT_ADDRESS_X,
        right: self.class::RIGHT_ADDRESS_X
      }[group.settings(:messages_letter).address_position&.to_sym]
      x_coords ||= 0

      top = top_offset(group)
      y_coords = pdf.bounds.top - (top.to_f.cm - page.margins[:top]) if top.present?
      y_coords ||= cursor

      [x_coords, y_coords]
    end

    def left_offset(group)
      group.settings(:messages_letter).left_address_offset
    end

    def top_offset(group)
      group.settings(:messages_letter).top_address_offset
    end
  end
end
