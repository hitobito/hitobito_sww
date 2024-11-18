# frozen_string_literal: true

#  Copyright (c) 2024, Puzzle ITC. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

[
  Invoice,
  InvoiceArticle,
  InvoiceConfig,
  InvoiceList,
  Group,
  Payment,
  PaymentReminder
].map(&:reset_column_information)
