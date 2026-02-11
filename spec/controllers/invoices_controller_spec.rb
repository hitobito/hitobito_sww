# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe InvoicesController do
  let(:group) { groups(:berner_wanderwege) }
  let(:person_a) { Fabricate(:person, household_key: "family_a") }
  let(:person_b) { Fabricate(:person, household_key: "family_b") }
  let(:user) do
    Fabricate(Group::Geschaeftsstelle::Kassier.sti_name,
      group: groups(:berner_geschaeftsstelle)).person
  end

  before { sign_in(user) }

  def position_of(invoice) = assigns(:invoices).find_index(invoice)

  context "GET#index" do
    it "can sort by household_key" do
      invoice_a = Fabricate(:invoice, group: group, recipient: person_a)
      invoice_b = Fabricate(:invoice, group: group, recipient: person_b)

      get :index, params: {group_id: group.id}
      expect(assigns(:invoices)).to include(invoice_a, invoice_b)

      get :index, params: {group_id: group.id, sort: :household_key, sort_dir: :asc}
      expect(position_of(invoice_a)).to be < position_of(invoice_b)

      get :index, params: {group_id: group.id, sort: :household_key, sort_dir: :desc}
      expect(position_of(invoice_b)).to be < position_of(invoice_a)
    end
  end
end
