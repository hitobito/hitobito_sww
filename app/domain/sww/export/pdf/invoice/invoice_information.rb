# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice::InvoiceInformation
  def render
    bounding_box([303, 480], width: 180, height: 20) do
      text contents.shift, align: :right if contents.any?
    end

    bounding_box([303, 505], width: 180, height: 20) do
      text contents.shift, align: :right, valign: :bottom if contents.any?
    end
  end

  private

  def contents
    @contents ||= [].tap do |items|
      items << information if invoice.issued_at.present?
      items << member_number if member_number.present?
    end
  end

  def information
    if @options[:reminders] && invoice.payment_reminders.exists?
      labeled_information(:invoice_date,
        I18n.l(invoice.latest_reminder.created_at.to_date)).join(" ")
    else
      labeled_information(:invoice_date, I18n.l(invoice.issued_at)).join(" ")
    end
  end

  def group
    invoice.group
  end

  def member_number
    invoice.recipient.try(:member_number).then do |number|
      "#{Person.human_attribute_name(:member_number)}: #{number}" if number.present?
    end
  end
end
