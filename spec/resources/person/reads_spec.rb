#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

RSpec.describe PersonResource, type: :resource do
  # TODO: remove method after core branch `feature/json-api-finis` is merged
  def set_ability(&block)
    ability = Class.new do
      include CanCan::Ability
      attr_reader :user

      define_method(:initialize) do
        @user = Fabricate(:person)
        @self_before_instance_eval = eval "self", block.binding
        instance_eval(&block)
      end

      def method_missing(method, *args, &block)
        @self_before_instance_eval.send method, *args, &block
      end
    end

    Graphiti.context[:object].current_ability = ability.new
    allow(Graphiti.context[:object]).to receive(:can?) do |*args|
      Graphiti.context[:object].current_ability.can?(*args)
    end
  end

  describe 'serialization' do
    let!(:person) { Fabricate(:person, birthday: Date.today, gender: 'm') }
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
      set_ability { can :manage, :all }

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
      let!(:updater_person) { Fabricate(:person) }
      let!(:updated_person) { Fabricate(:person, updater_id: updater_person.id) }

      before do
        params[:filter] = { id: updated_person.id.to_s }
        params[:include] = 'updated_by'
      end

      it 'it works' do
        set_ability { can :manage, :all }

        render

        sl = d[0].sideload(:updated_by)
        expect(sl.jsonapi_type).to eq('people')
        expect(sl.id).to eq(updater_person.id)
      end
    end
  end
end
