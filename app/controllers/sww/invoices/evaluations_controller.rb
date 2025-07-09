# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Invoices::EvaluationsController
  extend ActiveSupport::Concern

  def render_tabular(format)
    exported_data = case format
    when :csv then Export::Tabular::Invoices::EvaluationList.csv(table_rows,
      tabular_metadata)
    when :xlsx then Export::Tabular::Invoices::EvaluationList.xlsx(table_rows,
      tabular_metadata)
    end
    send_data exported_data, type: format, filename: "invoices_evaluation_#{from}-#{to}.#{format}"
  end

  private

  def tabular_metadata
    {
      layer: group.name,
      from: from,
      to: to,
      printed_by: current_user.person_name
    }
  end
end
