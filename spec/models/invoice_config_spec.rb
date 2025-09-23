# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe InvoiceConfig do
  let(:group) { groups(:schweizer_wanderwege) }
  let(:invoice_config) { group.invoice_config }

  describe "header validation" do
    it "validates presence when use_header is true" do
      invoice_config.use_header = true
      invoice_config.header = ""

      expect(invoice_config).not_to be_valid
      expect(invoice_config.errors.full_messages).to eq ["Kopfzeile muss ausgefüllt werden"]
    end

    it "is valid without use_header = false and no header" do
      invoice_config.use_header = false
      invoice_config.header = ""

      expect(invoice_config).to be_valid
    end
  end
end
