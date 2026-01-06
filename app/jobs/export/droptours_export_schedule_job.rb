# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class Export::DroptoursExportScheduleJob < RecurringJob
  run_every 1.day

  def perform_internal
    # Schedule an upload job for each Fachorganisation with droptours_export enabled
    fachorganisation_ids.each do |fachorganisation_id|
      Export::DroptoursExportUploadJob.new(fachorganisation_id).enqueue!
    end
  end

  private

  # Return all Fachorganisation IDs that have at least one Mitglieder group
  # with droptours_export enabled
  def fachorganisation_ids
    Group::Mitglieder
      .joins(:mounted_attributes)
      .where(mounted_attributes: {key: "droptours_export"})
      .select { _1.droptours_export == true }
      .pluck(:layer_group_id).uniq.sort
  end

  def next_run
    interval.from_now.midnight + 15.minutes
  end
end
