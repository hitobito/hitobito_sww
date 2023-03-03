#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

RSpec.describe RoleResource, type: :resource do
  describe 'serialization' do
    let!(:role) { roles(:zuercher_mitglied) }

    before do
      params[:filter] = { id: role.id }
    end

    it 'works' do
      render

      data = jsonapi_data[0]

      expect(data.attributes.symbolize_keys.keys).to include :role_class, :role_type

      expect(data.id).to eq(role.id)
      expect(data.jsonapi_type).to eq('roles')
      expect(data.role_class).to eq role.class.name
      expect(data.role_type).to eq role.class.label
    end
  end
end
