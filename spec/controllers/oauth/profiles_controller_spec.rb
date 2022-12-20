#  frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Oauth::ProfilesController do
  let(:benutzerkonten) { Group::Benutzerkonten.create!(name: 'CMS Benutzer', parent: groups(:schweizer_wanderwege)) }
  let(:cms_benutzer) do
    benutzer = Fabricate(Group::Benutzerkonten::Benutzerkonto.to_s, group: benutzerkonten).person
    benutzer.update!(sww_cms_profile_id: 42)
    benutzer
  end
  let(:app) { Oauth::Application.create!(name: 'MyApp', redirect_uri: redirect_uri) }
  let(:redirect_uri) { 'urn:ietf:wg:oauth:2.0:oob' }

  let(:token) { app.access_tokens.create!(resource_owner_id: cms_benutzer.id, scopes: 'name email with_roles', expires_in: 2.hours) }

  context 'GET show' do
    context 'with name scope' do
      it 'renders sww_cms_profile_id' do
        @request.headers['X-Scope'] = 'name'
        get :show, params: { access_token: token.token }

        json = JSON.parse(response.body)

        expect(json).to be_present
        expect(json['id']).to eq(cms_benutzer.id)
        expect(json).to have_key('sww_cms_profile_id')
        expect(json['email']).to eq(cms_benutzer.email)
        expect(json['sww_cms_profile_id']).to eq(42)
      end
    end

    context 'with with_roles scope' do
      it 'renders sww_cms_profile_id' do
        @request.headers['X-Scope'] = 'with_roles'

        get :show, params: { access_token: token.token }

        json = JSON.parse(response.body)

        expect(json).to be_present
        expect(json['id']).to eq(cms_benutzer.id)
        expect(json).to have_key('sww_cms_profile_id')
        expect(json['email']).to eq(cms_benutzer.email)
        expect(json['sww_cms_profile_id']).to eq(42)
      end
    end

    context 'without scope' do
      it 'does not render sww_cms_profile_id' do
        @request.headers['X-Scope'] = ''

        get :show, params: { access_token: token.token }

        json = JSON.parse(response.body)

        expect(json).to be_present
        expect(json['id']).to eq(cms_benutzer.id)
        expect(json).to_not have_key('sww_cms_profile_id')
        expect(json['email']).to eq(cms_benutzer.email)
      end
    end
  end
end
