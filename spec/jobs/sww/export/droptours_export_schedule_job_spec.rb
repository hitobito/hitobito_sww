# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Export::DroptoursExportScheduleJob do
  subject(:job) { described_class.new }

  let(:fachorganisation_ids) { [42, 43] }

  before do
    # Stub Settings.droptours_export.sftp_config with the test fachorganisation_ids
    configs = fachorganisation_ids.map { OpenStruct.new(fachorganisation_id: _1) }
    allow(Settings.droptours_export).to receive(:sftp_config).and_return(configs)
  end

  context "rescheduling" do
    it "reschedules for tomorrow at 15 minutes past midnight" do
      job.perform
      next_job = Delayed::Job.find_by("handler like '%DroptoursExportScheduleJob%'")
      expect(next_job.run_at).to eq Time.zone.tomorrow + 15.minutes
    end
  end

  context "perform" do
    it "schedules jobs for all configured fachorganisation_id" do
      expect { job.perform }
        .to change { Delayed::Job.count }
        # 2 for the fachorganisation uploads + 1 for the rescheduled job
        .by(fachorganisation_ids.length + 1)

      fachorganisation_ids.each do |fachorganisation_id|
        expect(Delayed::Job.where("handler like '%fachorganisation_id: #{fachorganisation_id}%'"))
          .to be_present
      end
    end
  end
end
