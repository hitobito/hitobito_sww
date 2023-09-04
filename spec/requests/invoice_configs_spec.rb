# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

require 'spec_helper'

describe "InvoiceConfigs" do
  describe "GET /invoice_configs" do
    include Devise::Test::IntegrationHelpers

    let(:group) { groups(:schweizer_wanderwege) }
    let(:person) { people(:zuercher_leiter)  }
    let(:config) { group.invoice_config }

    before do
      group.create_invoice_config!(payee: "foo\nbar\nbuzz", iban: "CH93 0076 2011 6238 5295 7")
      Fabricate(Group::SchweizerWanderwege::Support.name.to_sym, group: group, person: person)
      sign_in(person)
    end

    def page
      @page ||= Hash.new
      @page.fetch(response.body.hash, Capybara::Node::Simple.new(response.body))
    end

    def dl_css_path(kind, list: 4, item: 1)
      "dl:nth-of-type(#{list}) #{kind}:nth-of-type(#{item})"
    end

    it "can change separator field" do
      get group_invoice_config_path(group_id: group.id)
      expect(response).to have_http_status(200)
      expect(page).to have_css(dl_css_path(:dt), text: "Trennlinie")
      expect(page).to have_css(dl_css_path(:dd), text: "ja")

      patch group_invoice_config_path(group_id: group.id, params: { invoice_config: { separators: 0 } })
      expect(response).to be_redirect
      follow_redirect!
      expect(config.reload.separators).to eq false

      expect(page).to have_css(dl_css_path(:dt), text: "Trennlinie")
      expect(page).to have_css(dl_css_path(:dd), text: "nein")
    end
  end
end
