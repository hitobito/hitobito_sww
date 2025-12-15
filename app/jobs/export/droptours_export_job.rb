# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class Export::DroptoursExportJob < Export::ExportBaseJob
  ENCODING_UTF_8 = "UTF-8"
  CSV_COL_SEP = "$"

  self.parameters = PARAMETERS + [:fachorganisation_id]
  self.use_background_job_logging = true

  def initialize(format, user_id, fachorganisation_id, **options)
    @fachorganisation_id = fachorganisation_id

    super(format, user_id, **options.reverse_merge(encoding: ENCODING_UTF_8,
      filename: generate_filename))
  end

  def data
    tabular = Export::Tabular::People::DroptoursMitglieder.new(fachorganisation)
    encoding = @options.fetch(:encoding)
    [
      Export::Csv::Generator.new(tabular,
        csv_handler_class: CSV,
        encoding:,
        utf8_bom: encoding == "UTF-8",
        col_sep: CSV_COL_SEP).call,
      summary_line(tabular)
    ].join
  end

  private

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

  def summary_line(tabular)
    count = tabular.list.size
    date = I18n.l(Time.zone.now.to_date, format: "%d.%m.%Y")
    time = Time.zone.now.strftime("%H:%M")
    [
      "* * * Dateiende * * *",
      "#{fachorganisation.id} - #{fachorganisation.name}",
      "Anzahl Datensätze: #{count}",
      date,
      time
    ].join(" / ").encode(ENCODING_UTF_8)
  end
end
