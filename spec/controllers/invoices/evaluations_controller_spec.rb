# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Invoices::EvaluationsController do
  let(:person) {
    Fabricate(Group::Geschaeftsstelle::Kassier.sti_name.to_sym,
      group: groups(:zuercher_geschaeftsstelle)).person
  }

  before do
    sign_in(person)
  end

  it "renders tabular using metadata" do
    metadata = {
      layer: "Zürcher Wanderwege",
      from: Date.new(2022, 1, 1),
      to: Date.new(2022, 3, 31),
      printed_by: person.person_name
    }

    expect(Export::Tabular::Invoices::EvaluationList).to receive(:xlsx)
      .with(any_args, metadata)

    get :show, format: :xlsx, params: {group_id: groups(:zuercher_wanderwege).id,
                                       from: "01.01.2022",
                                       to: "31.03.2022"}
  end
end
