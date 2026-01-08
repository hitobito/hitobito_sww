# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Export::DroptoursExportUploadJob do
  let(:fachorganisation) { groups(:berner_wanderwege) }
  let(:sftp) { double(:sftp) }
  let(:sftp_config) do
    YAML.safe_load <<~YAML
      {
        #{fachorganisation.id}: {
          host: "sftp.example.com",
          port: 22,
          user: "testuser",
          password: "secret123",
          remote_path: "droptours/uploads"
        }
      }
    YAML
  end

  let(:config_file) { Tempfile.new(["droptours-config", ".yml"]) }

  subject(:job) { described_class.new(fachorganisation.id) }

  before do
    allow(Sftp).to receive(:new).and_return(sftp)

    config_file.write(YAML.dump(sftp_config))
    config_file.rewind
    allow(Export::DroptoursUploadConfig).to receive(:instance)
      .and_return(Export::DroptoursUploadConfig.new(config_file.path))
  end

  it "#upload_path prepends the job filename with the remote_path" do
    expect(job.upload_path.to_s).to eq [sftp_config.dig(fachorganisation.id, "remote_path"),
      job.filename].join("/")
  end

  it "#perform uploads csv data to upload_path" do
    expect(sftp).to receive(:upload_file).with(job.csv, job.upload_path)

    job.perform
  end
end
