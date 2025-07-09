# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::InvoiceAbility
  extend ActiveSupport::Concern

  included do
    on(Invoice) do
      permission(:complete_finance).may(:show, :create, :edit, :update, :destroy).all
    end

    on(InvoiceList) do
      permission(:complete_finance).may(:update, :destroy, :create, :index_invoices).all
    end

    on(InvoiceArticle) do
      permission(:complete_finance).may(:show, :new, :create, :edit, :update, :destroy).all
    end

    on(InvoiceConfig) do
      permission(:complete_finance).may(:show, :edit, :update).all
    end

    on(Payment) do
      permission(:complete_finance).may(:create).all
    end

    on(PaymentReminder) do
      permission(:complete_finance).may(:create).all
    end
  end
end
