# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Invoice::PaymentSlipQr
  extend ActiveSupport::Concern

  included do
    alias_method_chain :separators, :configuration
  end

  def separators_with_configuration
    separators_without_configuration if invoice.invoice_config&.separators?
  end
end
