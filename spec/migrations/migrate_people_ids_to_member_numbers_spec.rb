# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"
require_relative "../../db/migrate/20260901000000_migrate_people_ids_to_member_numbers"

RSpec.describe MigratePeopleIdsToMemberNumbers, type: :migration do
  let(:migration_version) { 20260901000000 }
  let(:migration_context) { ActiveRecord::Base.connection_pool.migration_context }

  def connection
    ActiveRecord::Base.connection
  end

  def insert_person(id:, manual_member_number: "NULL")
    connection.execute(<<~SQL)
      INSERT INTO people (id, first_name, last_name, email, manual_member_number, created_at, updated_at)
      VALUES (#{id}, 'Test', 'Migration#{id}', 'migration-test-#{id}@example.com', #{manual_member_number}, NOW(), NOW())
    SQL
  end

  def insert_role(person_id:)
    group = groups(:schweizer_wanderwege)
    connection.execute(<<~SQL)
      INSERT INTO roles (person_id, group_id, type, created_at, updated_at)
      VALUES (#{person_id}, #{group.id}, '#{group.class.role_types.first}', NOW(), NOW())
    SQL
  end

  def mapping_row(old_id)
    connection
      .select_one("SELECT old_id, new_id FROM people_id_migration_map WHERE old_id = #{old_id}")
  end

  before do
    ActiveRecord::Migration.verbose = false
    connection.execute("DELETE FROM schema_migrations WHERE version = '#{migration_version}'")
    connection.execute("DROP TABLE IF EXISTS people_id_migration_map")
    connection.execute("ALTER TABLE people ADD COLUMN IF NOT EXISTS manual_member_number integer")
    connection.schema_cache.clear!
    ActiveRecord::Base.descendants.each(&:reset_column_information)
  end

  after do
    connection.schema_cache.clear!
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    ActiveRecord::Migration.verbose = true
  end

  describe "people_id_migration_map" do
    it "maps person without manual_member_number to old_id + 300_000" do
      insert_person(id: 101)

      migration_context.up(migration_version)

      expect(mapping_row(101)["new_id"]).to eq(300_101)
    end

    it "maps person with manual_member_number to that number" do
      insert_person(id: 102, manual_member_number: 500)

      migration_context.up(migration_version)

      expect(mapping_row(102)["new_id"]).to eq(500)
    end
  end

  describe "collision validation" do
    it "raises when two entries would get the same new_id" do
      insert_person(id: 200)                              # new_id = 300_200
      insert_person(id: 201, manual_member_number: 300_200) # new_id = 300_200 → collision

      expect { migration_context.up(migration_version) }
        .to raise_error(/member_number nicht eindeutig/)
    end
  end

  describe "people.id" do
    it "updates id for person without manual_member_number" do
      insert_person(id: 301)

      migration_context.up(migration_version)

      expect(connection.select_value("SELECT id FROM people WHERE id = 300_301")).to eq(300_301)
    end

    it "updates id for person with manual_member_number" do
      insert_person(id: 302, manual_member_number: 888)

      migration_context.up(migration_version)

      expect(connection.select_value("SELECT id FROM people WHERE id = 888")).to eq(888)
    end
  end

  describe "reference updates" do
    it "updates roles.person_id" do
      insert_person(id: 401)
      insert_role(person_id: 401)

      migration_context.up(migration_version)

      expect(connection.select_value("SELECT person_id FROM roles WHERE person_id = 300_401"))
        .to eq(300_401)
    end

    it "updates people.updater_id" do
      insert_person(id: 402) # updater
      insert_person(id: 403) # updated person
      connection.execute("UPDATE people SET updater_id = 402 WHERE id = 403")

      migration_context.up(migration_version)

      expect(connection.select_value("SELECT updater_id FROM people WHERE id = 300_403"))
        .to eq(300_402)
    end

    describe "versions.whodunnit" do
      def insert_version(whodunnit:, whodunnit_type: "Person", item_id: nil, item_type: "Person")
        item_id ||= whodunnit
        connection.execute(<<~SQL)
          INSERT INTO versions (item_type, item_id, event, whodunnit, whodunnit_type, created_at)
          VALUES ('#{item_type}', #{item_id}, 'update', #{connection.quote(whodunnit.to_s)}, #{connection.quote(whodunnit_type)}, NOW())
        SQL
        connection.select_value("SELECT MAX(id) FROM versions")
      end

      it "updates whodunnit for non-manual person (pass 1)" do
        insert_person(id: 501)
        version_id = insert_version(whodunnit: 501)

        migration_context.up(migration_version)

        expect(connection.select_value("SELECT whodunnit FROM versions WHERE id = #{version_id}"))
          .to eq("300501")
      end

      it "updates whodunnit for person with manual_member_number (pass 2)" do
        insert_person(id: 502, manual_member_number: 600)
        version_id = insert_version(whodunnit: 502)

        migration_context.up(migration_version)

        expect(connection.select_value("SELECT whodunnit FROM versions WHERE id = #{version_id}"))
          .to eq("600")
      end

      it "does not update whodunnit when whodunnit_type is not Person" do
        insert_person(id: 503)
        version_id = insert_version(whodunnit: 503, whodunnit_type: "System")

        migration_context.up(migration_version)

        expect(connection.select_value("SELECT whodunnit FROM versions WHERE id = #{version_id}"))
          .to eq("503")
      end
    end
  end

  describe "manual_member_number column" do
    it "drops the column" do
      migration_context.up(migration_version)

      expect(connection.column_exists?(:people, :manual_member_number)).to be false
    end
  end
end
