# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe "invoices/_table.html.haml" do
  let(:group) { groups(:berner_wanderwege) }
  let(:person) { people(:berner_wanderer).tap { |p| p.update(household_key: "the-household") } }
  let(:invoice) { Fabricate(:invoice, group: group, recipient: person) }
  let(:invoices) { group.issued_invoices }
  let(:paginated_invoices) { invoices.page(1).per(10) }

  subject(:dom) { Capybara::Node::Simple.new(render) }

  before do
    assign(:invoices, paginated_invoices)
    allow(view).to receive(:entries).and_return(paginated_invoices)
    allow(view).to receive(:parent).and_return(group)
    allow(view).to receive(:url_for).and_return("/invoices?sort=title&sort_dir=asc")
    allow(view).to receive(:sortable?).and_return(true)
    allow(view).to receive(:invoice_run).and_return(nil)
    allow(view).to receive(:group).and_return(group)
    allow(view).to receive(:current_user).and_return(person)
  end

  it "shows column for household_key" do
    expect(dom).to have_css("th", text: "Haushalts-ID")
    expect(dom).to have_css("td", text: "the-household")
  end
end
