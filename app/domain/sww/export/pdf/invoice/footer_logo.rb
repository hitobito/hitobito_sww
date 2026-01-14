# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice
  class FooterLogo < Export::Pdf::Section
    alias_method :invoice_config, :model

    def initialize(pdf, model, options)
      super

      @metadata = options[:metadata]
    end

    def render
      return unless invoice_config.logo_position == Sww::InvoiceConfig::LOGO_POSITION_BOTTOM_LEFT

      render_footer_logo
    end

    private

    def render_footer_logo
      repeat_footer_logo(pages_with_footer_logo) do
        pdf.bounding_box([-20, pdf.bounds.bottom + 10], width: pdf.bounds.width) do
          build_logo.render
        end
      end
    end

    def repeat_footer_logo(pages, &block)
      pdf.repeat(pages) do
        block.call
      end
    end

    def pages_with_footer_logo
      # The logo is only rendered in the footer if there is no payment slip
      # In case of a payment slip, the payment slip class handles the rendering of the logo.
      if invoice_config.logo_on_every_page
        Array(1..pdf.page_count) - @metadata[:pages_with_payment_slip]
      else
        @metadata[:first_pages_of_invoices] - @metadata[:pages_with_payment_slip]
      end
    end

    def build_logo
      ::Export::Pdf::Logo.new(
        pdf,
        invoice_config.logo,
        image_width: ::Export::Pdf::Invoice::Header::LOGO_WIDTH,
        image_height: ::Export::Pdf::Invoice::Header::LOGO_HEIGHT,
        position: :left
      )
    end
  end
end
