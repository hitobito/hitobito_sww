# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::Export::Pdf::Invoice::Articles

  def render # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    reminder = invoice.payment_reminders.last

    move_cursor_to 510
    pdf.move_down 1.cm
    font_size(12) { text title(reminder) }
    pdf.move_down 8
    text invoice.description

    if reminder
      pdf.move_down 8
      font_size(10) { text reminder.text }
    end

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
        pdf.table subtotal_data, position: :right, cell_style: { borders: [],
                                                              border_color: 'CCCCCC',
                                                              border_width: 0.5 } do
          rows(0..1).padding = [2, 0]

          row(1).font_style = :bold
          row(3).font_style = :bold
          row(1..3).borders = [:bottom, :top]
          row(1..3).padding = [5, 0]
          row(1..3).column(0).padding = [5, 15, 5, 0]

          column(1).align = :right
        end
      end
    end
  end

  def subtotal_data(total_i18n_key = 'invoices.pdf.total')
    decorated = invoice.decorate
    [
      [I18n.t('invoices.pdf.cost'), decorated.cost],
      [I18n.t('invoices.pdf.subtotal'), decorated.total],
      [I18n.t('invoices.pdf.donation'), nil],
      [I18n.t(total_i18n_key), nil]
    ]
  end

  private

  def articles
    articles = super
    articles[0][0] = 
      I18n.t('invoices.pdf.invoice_number') + ": #{invoice.sequence_number}"
    articles
  end

  def render_due_at
    return unless invoice.due_at.present?

    pdf.move_up 15
    text I18n.t('invoices.pdf.due_at') + ":      #{I18n.l(invoice.due_at)}"
  end

end
