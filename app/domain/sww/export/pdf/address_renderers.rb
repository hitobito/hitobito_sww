#  Copyright (c) 2026 Hitobito AG. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::AddressRenderers
  extend ActiveSupport::Concern

  included do
    # rubocop:todo Metrics/CyclomaticComplexity
    def address_position(letter_address_position) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      if model.is_a?(Invoice)
        super
      else
        left = left_position
        x_coords = left.to_f.cm - page.margins[:left] if left.present?

        x_coords ||= {
          left: left_address_x,
          right: right_address_x
        }[letter_address_position&.to_sym]
        x_coords ||= 0

        top = top_position
        y_coords = pdf.bounds.top - (top.to_f.cm - page.margins[:top]) if top.present?
        y_coords ||= cursor

        [x_coords, y_coords]
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def left_position
      group&.letter_left_address_position
    end

    def top_position
      group&.letter_top_address_position
    end
  end
end
