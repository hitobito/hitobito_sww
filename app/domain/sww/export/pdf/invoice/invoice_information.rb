# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::Export::Pdf::Invoice::InvoiceInformation

  def render
    return unless invoice.issued_at.present?

    bounding_box([290, 603], width: bounds.width, height: 80) do
      table(information, cell_style: { borders: [], padding: [1, 20, 0, 0] })
    end
  end

  private

  def information
    [labeled_information(:invoice_date, I18n.l(invoice.issued_at))]
  end

end
