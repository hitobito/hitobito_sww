# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


# This migration does not make any schema changes, it just transforms the data.
# If this migration breaks at a point far in the future, just replace it with a noop migration
# as the data migration is a one off task.
class MigrateToGeneratedMemberNumber2 < ActiveRecord::Migration[6.1]
  def up
    say "clearing member numbers >= 300'000 and all those of people without active role"
    execute <<~SQL
      UPDATE people
        SET manual_member_number = NULL
        FROM (
          SELECT DISTINCT person_id
          FROM roles
          WHERE end_on IS NULL
          OR end_on > NOW()
        ) active_roles
        WHERE people.id = active_roles.person_id
        OR manual_member_number >= 300000
        AND active_roles.person_id IS NULL;
    SQL

    say "clearing duplicate member numbers, keeping only the first occurrance"
    execute <<~SQL
      UPDATE people
        SET manual_member_number = NULL
        FROM (
          SELECT MIN(id) AS id, manual_member_number
          FROM people
          GROUP BY manual_member_number
          HAVING COUNT(*) > 1
        ) AS lowest_duplicate
        WHERE people.manual_member_number = lowest_duplicate.manual_member_number
        AND people.id <> lowest_duplicate.id;
    SQL
  end
end
