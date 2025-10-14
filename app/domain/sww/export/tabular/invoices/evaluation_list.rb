# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Tabular::Invoices::EvaluationList
  extend ActiveSupport::Concern

  included do
    def initialize(list, metadata = {})
      @metadata = metadata

      super(list)

      add_header_rows
    end
  end

  def add_header_rows # rubocop:todo Metrics/AbcSize
    header_rows << [I18n.t(:"invoices.evaluations.show.title")]
    header_rows << [Group.human_attribute_name(:layer_group),
      @metadata[:layer]]
    header_rows << [I18n.t("invoices.export.tabular.evaluation_list.daterange_label"),
      "#{@metadata[:from]&.strftime("%d.%m.%Y")}-" \
      "#{@metadata[:to]&.strftime("%d.%m.%Y")}"]
    header_rows << [I18n.t("invoices.export.tabular.evaluation_list.print_date"),
      (@metadata[:execution_date] || Time.zone.today).strftime("%d.%m.%Y")]
    header_rows << [I18n.t("invoices.export.tabular.evaluation_list.printed_by"),
      @metadata[:printed_by]]
  end
end
