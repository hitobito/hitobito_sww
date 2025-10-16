# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Export::Tabular::Invoices::EvaluationList do
  let(:list) do
    Export::Tabular::Invoices::EvaluationList.new([{name: "Membership", vat: 10, count: 2,
                                                    amount_paid: 10, cost_center: "Members",
                                                    account: "01-23456-7"}],
      {
        layer: "Berner Wanderwege",
        from: Date.new(2022, 1, 1),
        to: Date.new(2022, 12, 31),
        execution_date: Date.new(2023, 3, 1),
        printed_by: "Berner Wanderer"
      })
  end

  subject { list }

  it "builds header rows" do
    expect(subject.header_rows).to eq [["Buchungsbeleg"],
      ["Ebene", "Berner Wanderwege"],
      ["Kriterium (von-bis)", "01.01.2022-31.12.2022"],
      ["Druckdatum", "01.03.2023"],
      ["Gedruckt von", "Berner Wanderer"]]
  end
end
