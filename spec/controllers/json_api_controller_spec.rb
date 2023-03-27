# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe JsonApiController do
  context 'paper_trail' do
    before { PaperTrail.enabled = true }
    after { PaperTrail.enabled = false }

    let(:person) { people(:zuercher_wanderer) }

    controller(JsonApiController) do
      skip_authorization_check
      before_action { params.permit! }

      def update
        PersonResource.find(params).update_attributes and return render(plain: 'OK')

        render status: 500, plain: "ERROR"
      end
    end

    before do
      PersonResource.class_eval do
        self.endpoint_namespace = ''
        primary_endpoint('/json_api')
      end

      request.headers.merge!(jsonapi_headers)
    end
    
    let(:payload) do
      {
        id: person.id,
        data: {
          id: person.id.to_s,
          type: 'people',
          attributes: {
            last_name: 'JustMarried'
          }
        },
        donman_update_by: 'Donman was here'
      }
    end
    let(:params) { payload }

    context 'on request with ServiceToken' do
      let(:permitted_service_token) { service_tokens(:permitted_top_layer_token) }
      let(:params) { payload.merge(token: permitted_service_token.token) }

      it 'sets Version#specific_author' do
        expect do
          patch :update, params: params
          expect(response).to have_http_status(200)
        end.to change { person.reload.versions.size }.by(1)

        version = person.versions.last
        expect(version.perpetrator).to eq permitted_service_token
        expect(version.specific_author).to eq 'Donman was here'
      end
    end

    context 'on request with regular login' do
      let!(:mitarbeiter) { Fabricate(Group::SchweizerWanderwege::Support.name, group: groups(:schweizer_wanderwege)).person }

      before do
        sign_in(mitarbeiter)
        # mock check for user since sign_in devise helper is not setting any cookies
        allow_any_instance_of(described_class)
          .to receive(:user_session?).and_return(true)
      end

      it 'does not set Version#specific_author' do
        expect do
          patch :update, params: params
          expect(response).to have_http_status(200)
        end.to change { person.reload.versions.size }.by(1)

        version = person.versions.last
        expect(version.perpetrator).to eq mitarbeiter
        expect(version.specific_author).to eq nil
      end
    end
  end
end
