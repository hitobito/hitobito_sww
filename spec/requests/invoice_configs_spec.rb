# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe "InvoiceConfigs" do
  describe "GET /invoice_configs" do
    include Devise::Test::IntegrationHelpers

    let(:group) { groups(:schweizer_wanderwege) }
    let(:person) { people(:zuercher_leiter) }
    let(:config) { group.invoice_config }

    before do
      Fabricate(Group::SchweizerWanderwege::Support.name.to_sym, group: group, person: person)
      sign_in(person)
    end

    def page
      @page ||= {}
      @page.fetch(response.body.hash, Capybara::Node::Simple.new(response.body))
    end

    it "can change separator field" do
      get group_invoice_config_path(group_id: group.id)
      expect(response).to have_http_status(200) # might fail due to missing webpacker-compile
      expect(page.find("dl dt", text: "Trennlinie").find("+ dd").text).to eq "ja"

      patch group_invoice_config_path(group_id: group.id, params: {invoice_config: {separators: 0}})
      expect(response).to be_redirect
      follow_redirect!
      expect(config.reload.separators).to eq false

      expect(page.find("dl dt", text: "Trennlinie").find("+ dd").text).to eq "nein"
    end
  end
end
