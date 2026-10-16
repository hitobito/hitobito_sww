# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"
require_relative "../../db/migrate/20260901000000_add_member_number_to_people"

RSpec.describe AddMemberNumberToPeople, type: :migration do
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

  before do
    ActiveRecord::Migration.verbose = false
    connection.execute("DELETE FROM schema_migrations WHERE version = '#{migration_version}'")
    connection.execute("ALTER TABLE people ADD COLUMN IF NOT EXISTS manual_member_number integer")
    connection.execute("ALTER TABLE people DROP COLUMN IF EXISTS member_number CASCADE")
    connection.execute("DROP SEQUENCE IF EXISTS people_member_number_seq")
    connection.schema_cache.clear!
    ActiveRecord::Base.descendants.each(&:reset_column_information)
  end

  after do
    connection.schema_cache.clear!
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    ActiveRecord::Migration.verbose = true
  end

  describe "member_number backfill" do
    it "assigns id + 300_000 to people without manual_member_number" do
      insert_person(id: 101)

      migration_context.up(migration_version)

      expect(connection.select_value("SELECT member_number FROM people WHERE id = 101"))
        .to eq(300_101)
    end

    it "assigns manual_member_number to people that have one" do
      insert_person(id: 102, manual_member_number: 500)

      migration_context.up(migration_version)

      expect(connection.select_value("SELECT member_number FROM people WHERE id = 102"))
        .to eq(500)
    end

    it "raises when two entries would get the same member_number" do
      insert_person(id: 200)                                # member_number = 300_200
      insert_person(id: 201, manual_member_number: 300_200) # member_number = 300_200

      expect { migration_context.up(migration_version) }
        .to raise_error(/member_number nicht eindeutig/)
    end
  end

  describe "member_number column" do
    it "is not nullable" do
      migration_context.up(migration_version)

      column = connection.columns(:people).find { |c| c.name == "member_number" }
      expect(column.null).to be false
    end

    it "has a unique index" do
      migration_context.up(migration_version)

      expect(connection.index_exists?(:people, :member_number, unique: true)).to be true
    end
  end

  describe "people_member_number_seq" do
    it "starts above the maximum member_number" do
      insert_person(id: 301)

      migration_context.up(migration_version)

      max = connection.select_value("SELECT MAX(member_number) FROM people")
      expect(connection.select_value("SELECT last_value FROM people_member_number_seq"))
        .to eq(max)
    end

    it "assigns the next sequence value to newly inserted people" do
      insert_person(id: 302)

      migration_context.up(migration_version)

      max = connection.select_value("SELECT MAX(member_number) FROM people")
      new_id = connection.select_value(<<~SQL)
        INSERT INTO people (first_name, last_name, email, created_at, updated_at)
        VALUES ('Test', 'Sequence', 'migration-seq@example.com', NOW(), NOW())
        RETURNING id
      SQL
      member_number =
        connection.select_value("SELECT member_number FROM people WHERE id = #{new_id}")
      expect(member_number).to eq(max + 1)
    end
  end

  describe "manual_member_number column" do
    it "drops the column" do
      migration_context.up(migration_version)

      expect(connection.column_exists?(:people, :manual_member_number)).to be false
    end
  end
end
