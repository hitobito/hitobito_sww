# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::InvoiceConfig
  extend ActiveSupport::Concern

  LOGO_POSITION_BOTTOM_LEFT = "bottom_left"

  prepended do
    logo_positions << LOGO_POSITION_BOTTOM_LEFT

    has_rich_text :header

    validates :header, presence: true, if: :use_header?
    validates :header, no_attachments: true

    validate :logo_on_every_page_requires_position_bottom_left
  end

  private

  def logo_on_every_page_requires_position_bottom_left
    if logo_on_every_page && logo_position != LOGO_POSITION_BOTTOM_LEFT
      errors.add(
        :logo_on_every_page,
        :logo_on_every_page_only_allowed_for_position_bottom_left,
        valid_position: InvoiceConfig.logo_position_labels[:bottom_left]
      )
    end
  end
end
