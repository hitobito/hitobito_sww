#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

RSpec.describe PersonResource, type: :resource do
  let(:user) { user_role.person }
  let!(:user_role) { Fabricate(Group::GremiumProjektgruppe::Leitung.name, person: Fabricate(:person), group: groups(:berner_gremium)) }

  around do |example|
    RSpec::Mocks.with_temporary_scope do
      Graphiti.with_context(double({ current_ability: Ability.new(user) })) { example.run }
    end
  end

  describe 'serialization' do
    let!(:person) { Fabricate(:person, birthday: Date.today, gender: 'm') }
    let!(:role) { Fabricate(Group::GremiumProjektgruppe::Mitglied.name, person: person, group: groups(:berner_gremium)) }

    before { params[:filter] = { id: person.id } }

    def sww_simple_attrs
      [
        :title,
        :custom_salutation,
        :name_add_on,
        :magazin_abo_number,
        :sww_cms_profile_id
      ]
    end

    def sww_datetime_attrs
      [
        :updated_at
      ]
    end

    it 'works' do
      render

      data = jsonapi_data[0]

      expect(data.attributes.symbolize_keys.keys).to include *(sww_simple_attrs + sww_datetime_attrs)

      expect(data.id).to eq(person.id)
      expect(data.jsonapi_type).to eq('people')

      sww_simple_attrs.each do |attr|
        expect(data.public_send(attr)).to eq(person.public_send(attr))
      end

      sww_datetime_attrs.each do |attr|
        expect(Time.zone.parse data.public_send(attr)).to eq(person.public_send(attr))
      end
    end
  end

  describe 'sideloading' do
    describe 'updated_by' do
      let!(:updater_person) { Fabricate(Group::GremiumProjektgruppe::Mitglied.name, group: groups(:berner_gremium)).person }
      let!(:updated_person) { Fabricate(:person, updater_id: updater_person.id) }
      let!(:role) { Fabricate(Group::GremiumProjektgruppe::Mitglied.name, person: updated_person, group: groups(:berner_gremium)) }
      let(:person) { updater_person } # required by core ResourceSpecHelper which is included for resource specs

      before do
        params[:filter] = { id: updated_person.id.to_s }
        params[:include] = 'updated_by'
      end

      it 'it works' do
        render

        sl = d[0].sideload(:updated_by)
        expect(sl.jsonapi_type).to eq('people')
        expect(sl.id).to eq(updater_person.id)
      end
    end
  end
end
