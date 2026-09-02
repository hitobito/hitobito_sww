# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww
#
# Migrates people.id to member_number values:
#   - people with manual_member_number: new id = manual_member_number (1..299_999)
#   - people without:                   new id = old_id + 300_000     (300_001+)
#
# All referencing columns in other tables are updated in the same transaction.
# A two-pass strategy avoids unique constraint violations on polymorphic indexes.
# See: https://github.com/hitobito/hitobito_sww/issues/256
class MigratePeopleIdsToMemberNumbers < ActiveRecord::Migration[8.0]
  def up
    pk_constraint = ActiveRecord::Base.connection.select_value(<<~SQL)
      SELECT conname FROM pg_constraint
      WHERE conrelid = 'people'::regclass AND contype = 'p'
    SQL

    execute <<~SQL
      -- Alle betroffenen Tabellen sperren, damit eine parallel laufende Applikation
      -- mit dem alten Code-Stand keine inkonsistenten Eintraege erstellt.
      -- Die Locks werden am Ende der Transaktion automatisch freigegeben.
      LOCK TABLE
        people,
        roles, qualifications, assignments, event_invitations, event_participations,
        family_members, job_observations, label_formats, message_recipients,
        passes, payees, person_add_request_ignored_approvers, person_add_requests,
        person_duplicates, table_displays, people_managers, notes, subscriptions,
        phone_numbers, social_accounts, additional_emails, additional_addresses,
        taggings, active_storage_attachments, invoice_run_processed_subjects,
        groups, events, invoices, invoice_runs, messages,
        oauth_access_tokens, oauth_access_grants, hitobito_log_entries,
        sessions, versions
      IN ACCESS EXCLUSIVE MODE;

      CREATE TABLE people_id_migration_map AS
        SELECT id AS old_id,
               COALESCE(manual_member_number, id + 300000) AS new_id
        FROM people;

      -- Vorab-Validierung: Kollisionen ausschliessen
      DO $$ BEGIN
        IF EXISTS (
          SELECT new_id FROM people_id_migration_map GROUP BY new_id HAVING COUNT(*) > 1
        ) THEN RAISE EXCEPTION 'member_number nicht eindeutig!'; END IF;
      END $$;

      -- === Pass 1: nicht-manuelle Personen (new_id = old_id + 300000) ===
      UPDATE roles                             SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE qualifications                    SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE assignments                       SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE assignments                       SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id > 300000;
      UPDATE event_invitations                 SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE event_participations              SET participant_id = m.new_id FROM people_id_migration_map m WHERE participant_id = m.old_id AND participant_type = 'Person' AND m.new_id > 300000;
      UPDATE family_members                    SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE family_members                    SET other_id       = m.new_id FROM people_id_migration_map m WHERE other_id       = m.old_id AND m.new_id > 300000;
      UPDATE job_observations                  SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE label_formats                     SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE message_recipients                SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE passes                            SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE payees                            SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE person_add_request_ignored_approvers SET person_id  = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE person_add_requests               SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE person_add_requests               SET requester_id   = m.new_id FROM people_id_migration_map m WHERE requester_id   = m.old_id AND m.new_id > 300000;
      UPDATE person_duplicates                 SET person_1_id    = m.new_id FROM people_id_migration_map m WHERE person_1_id    = m.old_id AND m.new_id > 300000;
      UPDATE person_duplicates                 SET person_2_id    = m.new_id FROM people_id_migration_map m WHERE person_2_id    = m.old_id AND m.new_id > 300000;
      UPDATE table_displays                    SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE people_managers                   SET manager_id     = m.new_id FROM people_id_migration_map m WHERE manager_id     = m.old_id AND m.new_id > 300000;
      UPDATE people_managers                   SET managed_id     = m.new_id FROM people_id_migration_map m WHERE managed_id     = m.old_id AND m.new_id > 300000;
      UPDATE notes                             SET author_id      = m.new_id FROM people_id_migration_map m WHERE author_id      = m.old_id AND m.new_id > 300000;
      UPDATE notes                             SET subject_id     = m.new_id FROM people_id_migration_map m WHERE subject_id     = m.old_id AND subject_type = 'Person' AND m.new_id > 300000;
      UPDATE subscriptions                     SET subscriber_id  = m.new_id FROM people_id_migration_map m WHERE subscriber_id  = m.old_id AND subscriber_type = 'Person' AND m.new_id > 300000;
      UPDATE phone_numbers                     SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id > 300000;
      UPDATE social_accounts                   SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id > 300000;
      UPDATE additional_emails                 SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id > 300000;
      UPDATE additional_addresses              SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id > 300000;
      UPDATE taggings                          SET taggable_id    = m.new_id FROM people_id_migration_map m WHERE taggable_id    = m.old_id AND taggable_type = 'Person' AND m.new_id > 300000;
      UPDATE taggings                          SET tagger_id      = m.new_id FROM people_id_migration_map m WHERE tagger_id      = m.old_id AND tagger_type = 'Person' AND m.new_id > 300000;
      UPDATE active_storage_attachments        SET record_id      = m.new_id FROM people_id_migration_map m WHERE record_id      = m.old_id AND record_type = 'Person' AND m.new_id > 300000;
      UPDATE invoice_run_processed_subjects    SET subject_id     = m.new_id FROM people_id_migration_map m WHERE subject_id     = m.old_id AND subject_type = 'Person' AND m.new_id > 300000;
      UPDATE groups                            SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id > 300000;
      UPDATE groups                            SET updater_id     = m.new_id FROM people_id_migration_map m WHERE updater_id     = m.old_id AND m.new_id > 300000;
      UPDATE groups                            SET contact_id     = m.new_id FROM people_id_migration_map m WHERE contact_id     = m.old_id AND m.new_id > 300000;
      UPDATE groups                            SET deleter_id     = m.new_id FROM people_id_migration_map m WHERE deleter_id     = m.old_id AND m.new_id > 300000;
      UPDATE events                            SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id > 300000;
      UPDATE events                            SET updater_id     = m.new_id FROM people_id_migration_map m WHERE updater_id     = m.old_id AND m.new_id > 300000;
      UPDATE events                            SET contact_id     = m.new_id FROM people_id_migration_map m WHERE contact_id     = m.old_id AND m.new_id > 300000;
      UPDATE events                            SET application_contact_id = m.new_id FROM people_id_migration_map m WHERE application_contact_id = m.old_id AND m.new_id > 300000;
      UPDATE invoices                          SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id > 300000;
      UPDATE invoices                          SET recipient_id   = m.new_id FROM people_id_migration_map m WHERE recipient_id   = m.old_id AND recipient_type = 'Person' AND m.new_id > 300000;
      UPDATE invoice_runs                      SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id > 300000;
      UPDATE messages                          SET sender_id      = m.new_id FROM people_id_migration_map m WHERE sender_id      = m.old_id AND m.new_id > 300000;
      UPDATE oauth_access_tokens               SET resource_owner_id = m.new_id FROM people_id_migration_map m WHERE resource_owner_id = m.old_id AND m.new_id > 300000;
      UPDATE oauth_access_grants               SET resource_owner_id = m.new_id FROM people_id_migration_map m WHERE resource_owner_id = m.old_id AND m.new_id > 300000;
      UPDATE hitobito_log_entries              SET subject_id     = m.new_id FROM people_id_migration_map m WHERE subject_id     = m.old_id AND subject_type = 'Person' AND m.new_id > 300000;
      UPDATE sessions                          SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id > 300000;
      UPDATE versions                          SET item_id        = m.new_id FROM people_id_migration_map m WHERE item_id        = m.old_id AND item_type = 'Person' AND m.new_id > 300000;
      UPDATE versions                          SET main_id        = m.new_id FROM people_id_migration_map m WHERE main_id        = m.old_id AND main_type = 'Person' AND m.new_id > 300000;
      UPDATE versions                          SET whodunnit      = m.new_id::text FROM people_id_migration_map m WHERE whodunnit = m.old_id::text AND whodunnit_type = 'Person' AND m.new_id > 300000;
      UPDATE people                            SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id > 300000;
      UPDATE people                            SET updater_id     = m.new_id FROM people_id_migration_map m WHERE updater_id     = m.old_id AND m.new_id > 300000;

      -- === Pass 2: manuelle Personen (new_id = manual_member_number <= 299999) ===
      UPDATE roles                             SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE qualifications                    SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE assignments                       SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE assignments                       SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id <= 299999;
      UPDATE event_invitations                 SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE event_participations              SET participant_id = m.new_id FROM people_id_migration_map m WHERE participant_id = m.old_id AND participant_type = 'Person' AND m.new_id <= 299999;
      UPDATE family_members                    SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE family_members                    SET other_id       = m.new_id FROM people_id_migration_map m WHERE other_id       = m.old_id AND m.new_id <= 299999;
      UPDATE job_observations                  SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE label_formats                     SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE message_recipients                SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE passes                            SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE payees                            SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE person_add_request_ignored_approvers SET person_id  = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE person_add_requests               SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE person_add_requests               SET requester_id   = m.new_id FROM people_id_migration_map m WHERE requester_id   = m.old_id AND m.new_id <= 299999;
      UPDATE person_duplicates                 SET person_1_id    = m.new_id FROM people_id_migration_map m WHERE person_1_id    = m.old_id AND m.new_id <= 299999;
      UPDATE person_duplicates                 SET person_2_id    = m.new_id FROM people_id_migration_map m WHERE person_2_id    = m.old_id AND m.new_id <= 299999;
      UPDATE table_displays                    SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE people_managers                   SET manager_id     = m.new_id FROM people_id_migration_map m WHERE manager_id     = m.old_id AND m.new_id <= 299999;
      UPDATE people_managers                   SET managed_id     = m.new_id FROM people_id_migration_map m WHERE managed_id     = m.old_id AND m.new_id <= 299999;
      UPDATE notes                             SET author_id      = m.new_id FROM people_id_migration_map m WHERE author_id      = m.old_id AND m.new_id <= 299999;
      UPDATE notes                             SET subject_id     = m.new_id FROM people_id_migration_map m WHERE subject_id     = m.old_id AND subject_type = 'Person' AND m.new_id <= 299999;
      UPDATE subscriptions                     SET subscriber_id  = m.new_id FROM people_id_migration_map m WHERE subscriber_id  = m.old_id AND subscriber_type = 'Person' AND m.new_id <= 299999;
      UPDATE phone_numbers                     SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id <= 299999;
      UPDATE social_accounts                   SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id <= 299999;
      UPDATE additional_emails                 SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id <= 299999;
      UPDATE additional_addresses              SET contactable_id = m.new_id FROM people_id_migration_map m WHERE contactable_id = m.old_id AND contactable_type = 'Person' AND m.new_id <= 299999;
      UPDATE taggings                          SET taggable_id    = m.new_id FROM people_id_migration_map m WHERE taggable_id    = m.old_id AND taggable_type = 'Person' AND m.new_id <= 299999;
      UPDATE taggings                          SET tagger_id      = m.new_id FROM people_id_migration_map m WHERE tagger_id      = m.old_id AND tagger_type = 'Person' AND m.new_id <= 299999;
      UPDATE active_storage_attachments        SET record_id      = m.new_id FROM people_id_migration_map m WHERE record_id      = m.old_id AND record_type = 'Person' AND m.new_id <= 299999;
      UPDATE invoice_run_processed_subjects    SET subject_id     = m.new_id FROM people_id_migration_map m WHERE subject_id     = m.old_id AND subject_type = 'Person' AND m.new_id <= 299999;
      UPDATE groups                            SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id <= 299999;
      UPDATE groups                            SET updater_id     = m.new_id FROM people_id_migration_map m WHERE updater_id     = m.old_id AND m.new_id <= 299999;
      UPDATE groups                            SET contact_id     = m.new_id FROM people_id_migration_map m WHERE contact_id     = m.old_id AND m.new_id <= 299999;
      UPDATE groups                            SET deleter_id     = m.new_id FROM people_id_migration_map m WHERE deleter_id     = m.old_id AND m.new_id <= 299999;
      UPDATE events                            SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id <= 299999;
      UPDATE events                            SET updater_id     = m.new_id FROM people_id_migration_map m WHERE updater_id     = m.old_id AND m.new_id <= 299999;
      UPDATE events                            SET contact_id     = m.new_id FROM people_id_migration_map m WHERE contact_id     = m.old_id AND m.new_id <= 299999;
      UPDATE events                            SET application_contact_id = m.new_id FROM people_id_migration_map m WHERE application_contact_id = m.old_id AND m.new_id <= 299999;
      UPDATE invoices                          SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id <= 299999;
      UPDATE invoices                          SET recipient_id   = m.new_id FROM people_id_migration_map m WHERE recipient_id   = m.old_id AND recipient_type = 'Person' AND m.new_id <= 299999;
      UPDATE invoice_runs                      SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id <= 299999;
      UPDATE messages                          SET sender_id      = m.new_id FROM people_id_migration_map m WHERE sender_id      = m.old_id AND m.new_id <= 299999;
      UPDATE oauth_access_tokens               SET resource_owner_id = m.new_id FROM people_id_migration_map m WHERE resource_owner_id = m.old_id AND m.new_id <= 299999;
      UPDATE oauth_access_grants               SET resource_owner_id = m.new_id FROM people_id_migration_map m WHERE resource_owner_id = m.old_id AND m.new_id <= 299999;
      UPDATE hitobito_log_entries              SET subject_id     = m.new_id FROM people_id_migration_map m WHERE subject_id     = m.old_id AND subject_type = 'Person' AND m.new_id <= 299999;
      UPDATE sessions                          SET person_id      = m.new_id FROM people_id_migration_map m WHERE person_id      = m.old_id AND m.new_id <= 299999;
      UPDATE versions                          SET item_id        = m.new_id FROM people_id_migration_map m WHERE item_id        = m.old_id AND item_type = 'Person' AND m.new_id <= 299999;
      UPDATE versions                          SET main_id        = m.new_id FROM people_id_migration_map m WHERE main_id        = m.old_id AND main_type = 'Person' AND m.new_id <= 299999;
      UPDATE versions                          SET whodunnit      = m.new_id::text FROM people_id_migration_map m WHERE whodunnit = m.old_id::text AND whodunnit_type = 'Person' AND m.new_id <= 299999;
      UPDATE people                            SET creator_id     = m.new_id FROM people_id_migration_map m WHERE creator_id     = m.old_id AND m.new_id <= 299999;
      UPDATE people                            SET updater_id     = m.new_id FROM people_id_migration_map m WHERE updater_id     = m.old_id AND m.new_id <= 299999;

      -- PK selbst updaten (zwei Paesse):
      -- Pass 1 (non-manual): neue IDs >= 300001 existieren noch nicht, kein PK-Drop noetig.
      -- Pass 2 (manual): PK-Drop noetig, da manuelle IDs sich gegenseitig blockieren koennen.
      UPDATE people SET id = m.new_id FROM people_id_migration_map m WHERE id = m.old_id AND m.new_id > 300000;
      ALTER TABLE people DROP CONSTRAINT #{pk_constraint};
      UPDATE people SET id = m.new_id FROM people_id_migration_map m WHERE id = m.old_id AND m.new_id <= 299999;
      ALTER TABLE people ADD CONSTRAINT #{pk_constraint} PRIMARY KEY (id);
      SELECT setval('people_id_seq', (SELECT MAX(id) FROM people));

      ALTER TABLE people DROP COLUMN IF EXISTS manual_member_number CASCADE;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
