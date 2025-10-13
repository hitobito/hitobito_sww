# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice
  extend ActiveSupport::Concern

  LOGO_PADDING_TOP = 6.mm
  LOGO_PADDING_BOTTOM = 6.mm

  class RunnerSww < Export::Pdf::Invoice::Runner
    def invoice_page(pdf, invoice, options)
      @page_invoice = invoice
      @options = options

      super
    end

    def build_pdf(options)
      pdf = super

      Export::Pdf::Invoice::PageHeader.new(pdf, @invoice_config, {}).render
      Export::Pdf::Invoice::FooterLogo.new(pdf, @invoice_config, {metadata: @metadata}).render

      pdf
    end

    def sections
      sections = [
        Export::Pdf::Invoice::InvoiceInformation,
        Export::Pdf::Invoice::ReceiverAddress,
        Export::Pdf::Invoice::Articles
      ]

      if membership_card?
        [Sww::Export::Pdf::Messages::Letter::MembershipCard] + sections
      else
        sections
      end
    end

    # override the returned class if logo_position is set to "bottom_left"
    def payment_slip_qr_class
      return PaymentSlipWithLogo if @page_invoice.logo_position ==
        Sww::InvoiceConfig::LOGO_POSITION_BOTTOM_LEFT

      super
    end

    private

    def membership_card?
      @page_invoice.membership_card? && !render_reminders?
    end

    def render_reminders?
      @page_invoice.payment_reminders.exists? && @options[:reminders]
    end

    def customize(pdf)
      ::Export::Pdf::Font.new(super).customize
    end

    def render_logo(pdf, invoice_config, **options)
      # Rendering the logo in the bottom is handled by Sww::Export::Pdf::Invoice::FooterLogo
      return if invoice_config.logo_position == Sww::InvoiceConfig::LOGO_POSITION_BOTTOM_LEFT

      super
    end
  end

  prepended do
    self.runner = RunnerSww
  end
end
