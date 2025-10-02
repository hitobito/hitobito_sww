class RenameInvoicePositionAbovePaymentSlipToBottomLeft < ActiveRecord::Migration[7.1]
  def up
    InvoiceConfig.where(logo_position: "above_payment_slip").find_each do |invoice_config|
      invoice_config.update_column :logo_position, "bottom_left"
    end
  end

  def down
    InvoiceConfig.where(logo_position: "bottom_left").find_each do |invoice_config|
      invoice_config.update_column :logo_position, "above_payment_slip"
    end
  end
end
