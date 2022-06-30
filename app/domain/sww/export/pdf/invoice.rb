# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice
  extend ActiveSupport::Concern

  class RunnerSww < Export::Pdf::Invoice::Runner
    def invoice_page(pdf, invoice, options)
      @page_invoice = invoice
      super
    end

    def sections
      sections = [Export::Pdf::Invoice::InvoiceInformation,
                  Export::Pdf::Invoice::ReceiverAddress,
                  Export::Pdf::Invoice::Articles]


      if membership_card?
        [Sww::Export::Pdf::Messages::Letter::MembershipCard] + sections
      else
        sections
      end
    end

    def membership_card?
      @page_invoice.membership_card?
    end
  end

  prepended do
    self.runner = RunnerSww
  end
end
