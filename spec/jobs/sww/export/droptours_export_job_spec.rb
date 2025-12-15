# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Export::DroptoursExportJob do
  let(:user) { people(:zuercher_leiter) }
  let(:group) { groups(:berner_wanderwege) }

  let(:filename) { AsyncDownloadFile.create_name("droptours_export", user.id) }
  let(:file) { AsyncDownloadFile.from_filename(filename, :csv) }
  let(:csv) {
    # read the CSV and remove the UTF-8 BOM if present
    CSV.parse(file.read.delete_prefix!("\xEF\xBB\xBF"),
      col_sep: described_class::CSV_COL_SEP,
      headers: true)
  }

  it "works" do
    Export::DroptoursExportJob.new(:csv, user.id, group.id, filename:).perform

    expect(file.generated_file).to be_attached

    expect(csv).to have(2).items # 1 Person + 1 Summary Line

    person_row = csv.first
    expect(person_row["id"]).to eq people(:berner_wanderer).id.to_s
    expect(person_row["date_of_joining"])
      .to eq roles(:berner_mitglied).created_at.to_date.strftime("%d.%m.%Y")

    summary_row = csv.each.to_a.last
    expect(summary_row["id"]).to match(/Dateiende/)
    # not really a csv line, so only the first column is filled
    expect(summary_row.fields.compact.size).to eq 1
  end
end
