#  frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Oauth::ProfilesController do
  let(:user) { people(:zuercher_wanderer) }
  let(:token) { Fabricate(:access_token, resource_owner_id: user.id) }
  let(:app) { Oauth::Application.create!(name: 'MyApp', redirect_uri: redirect_uri) }
  let(:redirect_uri) { 'urn:ietf:wg:oauth:2.0:oob' }

  let(:token) { app.access_tokens.create!(resource_owner_id: user.id, scopes: 'openid', expires_in: 2.hours) }

  context 'GET show' do
    context 'with name scope' do
      it 'does not render sww_cms_profile_id' do
        get :show, params: { access_token: token.token }

        require 'pry'; binding.pry unless $pstop
        json = JSON.parse(response.body)

        expect(json)
      end
    end
  end
end
