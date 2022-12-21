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

  before do
    wanderer.update!(magazin_abo_number: 42,
                     title: 'Professor',
                     custom_salutation: 'Sälü dü',
                     name_add_on: 'Dude'
                    )
  end

  let(:sww_custom_attrs) do
    %w(title custom_salutation name_add_on magazin_abo_number) 
  end

  let(:permitted_service_token) { Fabricate(:service_token,
                                            layer: groups(:schweizer_wanderwege),
                                            name: 'permitted',
                                            people: true,
                                            permission: 'layer_and_below_full')  }
  let(:params) { { token: permitted_service_token.token } }

  describe 'GET #index' do
    context 'with service token' do
      context 'authorized' do
        it 'includes sww custom attributes' do
          jsonapi_get '/api/people', params: params

          expect(response).to have_http_status(200)
          expect(d.size).to eq(3)

          person = d.find {|p| p.attributes[:id].to_i == wanderer.id }

          expect(person.id).to eq(wanderer.id)
          expect(person.jsonapi_type).to eq('people')

          sww_custom_attrs.each do |attr|
            expect(person.attributes.key?(attr)).to eq(true)

            expect(person.send(attr.to_sym)).to eq(wanderer.send(attr.to_sym))
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'with service token' do
      context 'authorized' do
        it 'includes sww custom attributes' do
          jsonapi_get "/api/people/#{wanderer.id}", params: params

          expect(response).to have_http_status(200)

          person = d

          expect(person.id).to eq(wanderer.id)
          expect(person.jsonapi_type).to eq('people')

          sww_custom_attrs.each do |attr|
            expect(person.attributes.key?(attr)).to eq(true)

            expect(person.send(attr.to_sym)).to eq(wanderer.send(attr.to_sym))
          end
        end
      end
    end
  end

  describe 'PATCH #update' do
    let(:payload) do
      {
        data: {
          id: @person_id.to_s,
          type: 'people',
          attributes: {
            magazin_abo_number: 4435
          }
        }
      }
    end
    let(:params) { payload.merge({ token: permitted_service_token.token }) }

    before { PaperTrail.enabled = true }
    after { PaperTrail.enabled = false }

    context 'with service token' do
      context 'authorized' do
        it 'updates person`s sww custom attributes' do
          @person_id = wanderer.id
          former_magazin_abo_nr = wanderer.magazin_abo_number

          jsonapi_patch "/api/people/#{@person_id}", params

          expect(response).to have_http_status(200)

          wanderer.reload

          expect(wanderer.magazin_abo_number).to eq(4435)

          latest_change = wanderer.versions.last

          changes = YAML.load(latest_change.object_changes)
          expect(changes).to eq({ 'magazin_abo_number' => [ 42, 4435 ]})
          expect(latest_change.perpetrator).to eq(permitted_service_token)
        end
      end
    end
  end
end
