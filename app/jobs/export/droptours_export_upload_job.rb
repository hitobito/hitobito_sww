# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class Export::DroptoursExportUploadJob < BaseJob
  self.parameters = [:fachorganisation_id]
  self.use_background_job_logging = true

  delegate :filename, to: :export_job

  def initialize(fachorganisation_id)
    @fachorganisation_id = fachorganisation_id
    super()
  end

  def perform
    I18n.with_locale(:en) do
      Sftp.new(sftp_config).upload_file(csv, upload_path)
    end
  end

  def upload_path
    Pathname.new(sftp_config.remote_path).join(filename)
  end

  def csv
    @csv ||= export_job.data
  end

  private

  def export_job
    @export_job ||= Export::DroptoursExportJob.new(:csv, nil, @fachorganisation_id)
  end

  def sftp_config
    @sftp_config ||= Settings.droptours_export.sftp_config.find do |config|
      config.fachorganisation_id == @fachorganisation_id
    end || raise("Missing SFTP configuration for Fachorganisation ID #{@fachorganisation_id}")
  end
end
