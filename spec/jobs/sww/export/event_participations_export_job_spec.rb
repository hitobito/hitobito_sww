# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require "spec_helper"

describe Sww::Export::EventParticipationsExportJob do
  subject {
    Export::EventParticipationsExportJob.new(format,
      user.id,
      event.id,
      group.id,
      params.merge(filename: filename))
  }

  let(:user) { people(:zuercher_leiter) }
  let(:event) { events(:top_course) }
  let(:group) { event.groups.first }
  let(:filename) { AsyncDownloadFile.create_name("event_participation_export", user.id) }
  let(:file) { AsyncDownloadFile.from_filename(filename, format) }

  context "export participations list" do
    let(:format) { :csv }
    let(:params) { {filter: "all", participations_list: true} }
    let(:expected_columns_count) { 6 }

    it "and saves it" do
      subject.perform

      lines = file.read.lines
      expect(lines.size).to eq(2)
      expect(lines[0]).to match(Regexp.new("^#{Export::Csv::UTF8_BOM}Vorname;Nachname"))
      expect(lines[0].split(";").count).to match(expected_columns_count)
      expect(file.generated_file).to be_attached
    end

    context "without permissions" do
      let(:user) { people(:zuercher_wanderer) }

      it "uses default exporter" do
        subject.perform

        lines = file.read.lines
        expect(lines[0].split(";").count).to_not match(expected_columns_count)
      end
    end
  end
end
