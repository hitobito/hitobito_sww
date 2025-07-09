# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice::Articles
  def render # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    move_cursor_to 510
    pdf.move_down 1.cm
    font_size(12) { text title }
    pdf.move_down 8
    render_description if render_description?
    render_reminder if render_reminder?
    pdf.move_down 10
    pdf.font_size(8) { articles_table }

    invoice.hide_total? ? sum_box_with_donation_without_total : total_box
    render_due_at

    pdf.move_down 4
    font_size(8) { text invoice.payment_information }
  end

  def sum_box_with_donation_without_total
    bounding_box([0, cursor], width: bounds.width) do
      font_size(8) do
        data = total_data
        pdf.table data, position: :right, column_widths: {0 => 100},
          cell_style: {borders: [],
                       border_color: "CCCCCC",
                       border_width: 0.5} do
          last_row_index = data.size.pred
          rows(0..last_row_index).padding = [2, 0]

          row(last_row_index).font_style = :bold
          row(last_row_index - 2).font_style = :bold
          row(last_row_index).borders = [:bottom, :top]
          row(last_row_index).padding = [5, 0]
          row(last_row_index).column(0).padding = [5, 15, 5, 0]

          column(1).align = :right
        end
      end
    end
  end

  def total_data
    decorated = invoice.decorate
    if invoice.hide_total?
      data = super
      data.slice!(data.size - 4)
      data.slice!(data.size - 1)
      data +
        [
          [I18n.t("invoices.pdf.#{invoice.payments.any? ? "amount_open" : "subtotal"}"),
            decorated.amount_open],
          [I18n.t("invoices.pdf.donation"), nil],
          [I18n.t("invoices.pdf.total"), nil]
        ]
    else
      super
    end
  end

  private

  def articles
    articles = super

    invoice_info = "#{I18n.t("invoices.pdf.invoice_number")}: #{invoice.sequence_number}"
    invoice_info += " #{I18n.t("invoices.pdf.from", date: I18n.l(invoice.issued_at))}" if invoice.issued_at.present?

    articles[0][0] = invoice_info
    articles
  end

  def render_due_at
    return if invoice.due_at.blank?

    pdf.move_up 15
    text I18n.t("invoices.pdf.due_at") + ":      #{I18n.l(invoice.due_at)}"
  end
end
