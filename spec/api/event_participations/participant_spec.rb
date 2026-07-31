# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

RSpec.describe "event_participations participant", type: :request do
  it_behaves_like "jsonapi authorized requests", person: nil, required_scopes: [] do
    let(:service_token) { service_tokens(:permitted_top_layer_token) }

    let(:event) { events(:top_course) }
    let(:participant) { Fabricate(:person, additional_information: "internal note") }
    let!(:participation) do
      Fabricate(:event_participation, event: event, participant: participant, active: true)
    end

    subject(:make_request) do
      jsonapi_get "/api/event_participations",
        params: {include: "participant", filter: {event_id: event.id}}
    end

    def participant_attributes
      json["included"].to_a
        .find { |inc| inc["type"] == "people" && inc["id"] == participant.id.to_s }
        .fetch("attributes")
    end

    # The subscription and cms data is not shown in the web UI on a participation,
    # so the API must not show it either, unless show_details permission on the person is given.
    it "does not expose the subscription and cms data of a participant without any role" do
      make_request
      expect(response.status).to eq(200), response.body

      expect(participant_attributes).to have_key("additional_information")
      expect(participant_attributes).to have_key("title")
      %w[magazin_abo_number sww_cms_profile_id].each do |attr|
        expect(participant_attributes).not_to have_key(attr)
      end
    end
  end
end
