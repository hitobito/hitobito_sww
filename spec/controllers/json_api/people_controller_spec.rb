# frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe JsonApi::PeopleController, type: [:request] do
  # reset locale back to :de for other specs
  after { I18n.locale = :de }

  let(:params) { {} }
  let(:wanderer) { people(:zuercher_wanderer) }
  let(:permitted_service_token) { Fabricate(:service_token,
                                            layer: groups(:zuercher_wanderwege),
                                            name: 'permitted',
                                            people: true,
                                            permission: 'layer_and_below_read')  }

  describe 'GET #show' do
    context 'with service token' do
      context 'authorized' do
        let(:params) { { token: permitted_service_token.token } }

        it 'returns sww_cms_profile_id' do
          jsonapi_get "/api/people/#{wanderer.id}", params: params

          expect(response).to have_http_status(200)

          person = d

          expect(person.id).to eq(wanderer.id)
          expect(person.jsonapi_type).to eq('people')

          expect(person.sww_cms_profile_id).to be_present
          expect(person.sww_cms_profile_id).to eq(42)
        end
      end
    end

    context 'with signed in user session' do
      context 'authorized' do
        before do
          sign_in(wanderer)
          # mock check for user since sign_in devise helper is not setting any cookies
          allow_any_instance_of(described_class)
            .to receive(:user_session?).and_return(true)
        end

        it 'returns sww_cms_profile_id' do
          jsonapi_get "/api/people/#{wanderer.id}", params: params

          expect(response).to have_http_status(200)

          person = d

          expect(person.id).to eq(wanderer.id)
          expect(person.jsonapi_type).to eq('people')

          expect(person.sww_cms_profile_id).to be_present
          expect(person.sww_cms_profile_id).to eq(42)
        end
      end
    end

    context 'with personal oauth access token' do
      context 'authorized' do
        let(:token) { Fabricate(:access_token, resource_owner_id: wanderer.id) }

        before do
          allow_any_instance_of(Authenticatable::Tokens).to receive(:oauth_token) { token }
          allow(token).to receive(:acceptable?) { true }
          allow(token).to receive(:accessible?) { true }
        end

        it 'returns sww_cms_profile_id' do
          jsonapi_get "/api/people/#{wanderer.id}", params: params

          expect(response).to have_http_status(200)

          person = d

          expect(person.id).to eq(wanderer.id)
          expect(person.jsonapi_type).to eq('people')

          expect(person.sww_cms_profile_id).to be_present
          expect(person.sww_cms_profile_id).to eq(42)
        end
      end
    end
  end
end

