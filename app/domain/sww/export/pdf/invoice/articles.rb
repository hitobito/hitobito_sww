# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::Export::Pdf::Invoice::Articles
  extend ActiveSupport::Concern

  def total_box # rubocop:disable Metrics/MethodLength
    bounding_box([0, cursor], width: bounds.width) do
      font_size(8) do
        pdf.table total_data, position: :right, cell_style: { borders: [],
                                                              border_color: 'CCCCCC',
                                                              border_width: 0.5 } do
          rows(0..1).padding = [2, 0]

          row(1).font_style = :bold
          row(1).borders = [:bottom, :top]
          row(1).padding = [5, 0]
          row(1).column(0).padding = [5, 15, 5, 0]

          column(1).align = :right
        end
      end
    end
  end

  def total_data
    decorated = invoice.decorate
    [
      [I18n.t('invoices.pdf.cost'), decorated.cost],
      [I18n.t('invoices.pdf.total'), decorated.total]
    ]
  end
end
