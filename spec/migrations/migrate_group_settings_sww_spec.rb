# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Alpen-Club. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'
migration_file_name = File.expand_path('../../../db/migrate/20230921093341_migrate_group_settings_sww.rb', __FILE__)
require migration_file_name

describe MigrateGroupSettingsSww do
  before(:all) { self.use_transactional_tests = false }
  after(:all)  { self.use_transactional_tests = true }

  let(:migration) { described_class.new.tap { |m| m.verbose = false } }

  let(:layers) do
    [groups(:schweizer_wanderwege), groups(:berner_wanderwege)]
  end

  context '#up' do
    let(:group_settings) do
      layers.map do |group|
        MigrateGroupSettingsSww::LegacyGroupSetting.create!({
          var: :messages_letter,
          target: group,
          value: {
            'left_address_position' => '42',
            'top_address_position' => '95'
          }
        })
        MigrateGroupSettingsSww::LegacyGroupSetting.create!({
          var: :membership_card,
          target: group,
          value: {
            'top_position' => '4242',
            'left_position' => '9542'
          }
        })
      end
    end

    before do
      migration.down

      MigrateGroupSettingsSww::LegacyGroupSetting.delete_all
    end

    it 'migrates group settings' do
      group_settings

      migration.up

      expect(ActiveRecord::Base.connection.table_exists?('settings')).to eq(false)

      layers.each do |group|
        group.reload
        expect(group.letter_left_address_position).to eq(42)
        expect(group.letter_top_address_position).to eq(95)
        expect(group.membership_card_left_position).to eq(9542)
        expect(group.membership_card_top_position).to eq(4242)
      end
    end
  end

  context '#down' do
    after do
      migration.up
    end

    it 'migrates regular settings' do
      layers.each do |group|
        group.update!(letter_left_address_position: 42,
                      letter_top_address_position: 95,
                      membership_card_left_position: 4242,
                      membership_card_top_position: 9542)
      end

      migration.down

      expect(ActiveRecord::Base.connection.table_exists?('settings')).to eq(true)

      layers.each do |group|
        letter_setting = MigrateGroupSettingsSww::LegacyGroupSetting.find_by(target: group,
                                                                           var: :messages_letter)
        expect(letter_setting.value['left_address_position']).to eq(42)
        expect(letter_setting.value['top_address_position']).to eq(95)

        membership_card_setting = MigrateGroupSettingsSww::LegacyGroupSetting.find_by(target: group,
                                                                           var: :membership_card)
        expect(membership_card_setting.value['left_position']).to eq(4242)
        expect(membership_card_setting.value['top_position']).to eq(9542)
      end
    end
  end
end
