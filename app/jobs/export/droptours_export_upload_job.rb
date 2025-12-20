# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class Export::DroptoursExportUploadJob < BaseJob
  ENCODING_UTF_8 = "UTF-8"
  CSV_COL_SEP = "$"

  self.parameters = [:fachorganisation_id]
  self.use_background_job_logging = true

  def initialize(fachorganisation_id)
    @fachorganisation_id = fachorganisation_id
  end

  def perform
    I18n.with_locale(:en) do
      Sftp.new(sftp_config).upload_file(csv, upload_path)
    end
  end

  def upload_path
    Pathname.new(sftp_config.remote_path).join(filename)
  end

  def filename
    @filename ||= generate_filename
  end

  def csv
    @csv ||= generate_csv
  end

  private

  def generate_csv
    tabular = Export::Tabular::People::DroptoursMitglieder.new(fachorganisation)
    Export::Csv::Generator.new(tabular,
      csv_handler_class: CSV,
      encoding: ENCODING_UTF_8,
      utf8_bom: true,
      col_sep: CSV_COL_SEP).call
  end

  def fachorganisation
    @fachorganisation ||= Group::Fachorganisation.find(@fachorganisation_id)
  end

  def generate_filename
    csv = [
      fachorganisation.name,
      Group::Mitglieder.model_name.human,
      "Droptours",
      Date.current.strftime("%Y%m%d")
    ].join("-").gsub(/\s+/, "_") + ".csv"

    ActiveStorage::Filename.new(csv).sanitized
  end

  def sftp_config
    @sftp_config ||= Settings.droptours_export.sftp_config.find do |config|
      config.fachorganisation_id == @fachorganisation_id
    end || raise("Missing SFTP configuration for Fachorganisation ID #{@fachorganisation_id}")
  end
end
