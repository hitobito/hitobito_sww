# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class Export::DroptoursExportScheduleJob < RecurringJob
  run_every 1.day

  def perform_internal
    fachorganisation_ids.each do |fachorganisation_id|
      Export::DroptoursExportUploadJob.new(fachorganisation_id).enqueue!
    end
  end

  private

  def fachorganisation_ids
    Settings.droptours_export.sftp_config.map(&:fachorganisation_id)
  end

  def next_run
    interval.from_now.midnight + 15.minutes
  end
end
