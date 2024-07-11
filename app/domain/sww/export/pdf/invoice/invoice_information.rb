# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice::InvoiceInformation
  def render
    return if invoice.issued_at.blank?

    bounding_box([303, 480], width: 180, height: 20) do
      text information, align: :right
    end
  end

  private

  def information
    labeled_information(:invoice_date, I18n.l(invoice.issued_at)).join(" ")
  end
end
