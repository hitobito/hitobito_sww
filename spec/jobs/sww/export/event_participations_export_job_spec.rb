# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Sww::Export::EventParticipationsExportJob do
  include JobObservationSpecHelper

  subject {
    Export::EventParticipationsExportJob.new(format,
      user.id,
      event.id,
      group.id,
      params.merge(filename: "event_participation_export"))
  }

  let(:user) { people(:zuercher_leiter) }
  let(:event) { events(:top_course) }
  let(:group) { event.groups.first }
  let(:file) { subject.job_observation }

  before do
    subject.enqueue!
    subject.perform
  end

  context "export participations list" do
    let(:format) { :csv }
    let(:params) { {filter: "all", participations_list: true} }
    let(:expected_columns_count) { 6 }

    it "and saves it" do
      lines = read_data_from_generated_file(file).lines
      expect(lines.size).to eq(2)
      expect(lines[0]).to match(Regexp.new("^#{Export::Csv::UTF8_BOM}Vorname;Nachname"))
      expect(lines[0].split(";").count).to match(expected_columns_count)
      expect(file.generated_file).to be_attached
    end

    context "without permissions" do
      let(:user) { people(:zuercher_wanderer) }

      it "uses default exporter" do
        lines = read_data_from_generated_file(file).lines
        expect(lines[0].split(";").count).to_not match(expected_columns_count)
      end
    end
  end
end
