# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice
  class PageHeader < Export::Pdf::Section
    alias_method :invoice_config, :model

    def render
      return unless invoice_config.use_header
      return if invoice_config.header.blank?

      repeat_all do
        stamped :page_header
      end
    end

    private

    # Extracting the repeat block is necessary for mocking in the specs
    def repeat_all(&block)
      pdf.repeat(:all) do
        block.call
      end
    end

    def page_header
      pdf.bounding_box([0, pdf.bounds.top + page.margins[:top] - 30], width: pdf.bounds.width) do
        pdf.font_size 9 do
          pdf.markup invoice_config.header.to_s
        end
      end
    end
  end
end
