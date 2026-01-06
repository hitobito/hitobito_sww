# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Export::DroptoursExportScheduleJob do
  subject(:job) { described_class.new }

  let(:group) { groups(:berner_wanderwege) }

  describe "#perform" do
    it "reschedules for tomorrow at 15 minutes past midnight" do
      job.perform
      next_job = Delayed::Job.find_by("handler like '%DroptoursExportScheduleJob%'")
      expect(next_job.run_at).to eq Time.zone.tomorrow + 15.minutes
    end

    it "schedules jobs for all configured fachorganisation_id" do
      # 1 fachorganisation has droptours_export enabled on a mitglieder group (berner_mitglieder)
      # see spec/fixtures/mounted_attributes.yml
      expect { job.perform }
        .to change { Delayed::Job.count }
        # 1 for the enabled fachorganisation + 1 for the rescheduled job
        .by(2)

      upload_job = Export::DroptoursExportUploadJob.new(group.id)
      expect(Delayed::Job.where(handler: upload_job.to_yaml).count).to eq 1
    end
  end

  describe "#fachorganisation_ids" do
    it "returns fachorganisation IDs with droptours_export enabled" do
      expect(job.send(:fachorganisation_ids)).to eq [groups(:berner_wanderwege).id]

      groups(:zuercher_mitglieder).update(droptours_export: true)
      expect(job.send(:fachorganisation_ids).sort)
        .to match_array groups(:berner_wanderwege, :zuercher_wanderwege).map(&:id)
    end
  end
end
