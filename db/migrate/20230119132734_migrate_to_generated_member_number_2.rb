#  frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

# This migration does not make any schema changes, it just transforms the data.
# If this migration breaks at a point far in the future, just replace it with a noop migration
# as the data migration is a one off task.
class MigrateToGeneratedMemberNumber2 < ActiveRecord::Migration[6.1]
  def up
    return true unless ActiveRecord::Base.connection.class.to_s == 'ActiveRecord::ConnectionAdapters::Mysql2Adapter'

    say "clearing member numbers >= 300'000 and all those of people without active role"
    execute <<~SQL
      UPDATE people
        LEFT OUTER JOIN (
          SELECT DISTINCT person_id
          FROM roles
          WHERE deleted_at IS NULL
          OR deleted_at > UTC_TIMESTAMP()
        ) active_roles
        ON people.id = active_roles.person_id
        SET manual_member_number = NULL
        WHERE active_roles.person_id IS NULL
        OR manual_member_number >= 300000
    SQL

    say "clearing duplicate member numbers, keeping only the first occurrance"
    execute <<~SQL
      UPDATE people
        JOIN (SELECT MIN(id) AS ID, manual_member_number FROM people GROUP BY manual_member_number HAVING COUNT(*) > 1) lowest_duplicate
        ON people.manual_member_number = lowest_duplicate.manual_member_number
        SET people.manual_member_number = NULL
        WHERE people.id <> lowest_duplicate.id
    SQL
  end
end
