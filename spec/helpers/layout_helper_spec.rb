#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe LayoutHelper do
  let(:current_user) { Fabricate.build(:person) }

  describe '#render_nav?' do
    it 'returns false if user has no roles' do
      expect(render_nav?).to eq false
    end

    it 'returns false if user has only role Group::Benutzerkonten::Benutzerkonto' do
      current_user.roles << Group::Benutzerkonten::Benutzerkonto.new
      expect(render_nav?).to eq false
    end

    it 'returns true if user has role Group::Benutzerkonten::Benutzerkonto and others' do
      current_user.roles << Group::Benutzerkonten::Benutzerkonto.new
      current_user.roles << Group::Mitglieder::Passivmitglied.new
      expect(render_nav?).to eq true
    end

    it 'returns true if user.root?' do
      current_user.email = Settings.root_email
      expect(current_user).to be_root
      expect(render_nav?).to eq true
    end
  end
end
