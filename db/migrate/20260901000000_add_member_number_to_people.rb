# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww
#
# Fügt people.member_number als eigenes bigint-Attribut hinzu und befüllt es mit
# derselben Logik wie der bisherige Sww::Person#member_number-Accessor:
#   - Personen mit manual_member_number: member_number = manual_member_number (1..299_999)
#   - Personen ohne:                     member_number = id + 300_000       (300_001+)
#
# Neue Personen erhalten die member_number automatisch aus people_member_number_seq
# (Spalten-Default nextval, Sequenz-Start via setval auf MAX(member_number)).
# See: https://github.com/hitobito/hitobito_sww/issues/256
class AddMemberNumberToPeople < ActiveRecord::Migration[8.0]
  def up
    assert_unique_member_numbers!

    add_column :people, :member_number, :bigint

    execute <<~SQL
      UPDATE people SET member_number = COALESCE(manual_member_number, id + 300000)
    SQL

    change_column_null :people, :member_number, false
    add_index :people, :member_number, unique: true

    execute <<~SQL
      CREATE SEQUENCE people_member_number_seq OWNED BY people.member_number;
      SELECT setval('people_member_number_seq', (SELECT MAX(member_number) FROM people));
    SQL
    change_column_default :people, :member_number, -> { "nextval('people_member_number_seq')" }

    # CASCADE loescht die generated search_column, welche manual_member_number
    # referenziert; sie wird beim Deployment via search_column:build neu erstellt.
    execute "ALTER TABLE people DROP COLUMN IF EXISTS manual_member_number CASCADE"
  end

  def down
    add_column :people, :manual_member_number, :integer

    execute "UPDATE people SET manual_member_number = member_number"

    add_index :people, :manual_member_number, unique: true

    execute "ALTER TABLE people DROP COLUMN member_number CASCADE"
  end

  private

  def assert_unique_member_numbers!
    duplicates = select_value(<<~SQL.squish)
      SELECT COUNT(*) FROM (
        SELECT COALESCE(manual_member_number, id + 300000) AS member_number
        FROM people
        GROUP BY member_number
        HAVING COUNT(*) > 1
      ) AS duplicates
    SQL

    raise "member_number nicht eindeutig!" if duplicates.to_i.positive?
  end
end
