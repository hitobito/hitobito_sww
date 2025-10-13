class AddRenderLogoOnEveryPageToInvoiceConfig < ActiveRecord::Migration[7.1]
  def change
    add_column :invoice_configs, :logo_on_every_page, :boolean, default: false, null: false

    InvoiceConfig.reset_column_information
  end
end
