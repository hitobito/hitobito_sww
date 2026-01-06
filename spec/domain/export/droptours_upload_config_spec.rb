# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Export::DroptoursUploadConfig do
  let(:valid_config) do
    {
      42 => {
        host: "sftp.example.com",
        user: "testuser",
        password: "secret123",
        remote_path: "/uploads"
      },
      43 => "another value"
    }
  end

  let(:config_file) { Tempfile.new(["droptours-config", ".yml"]) }
  let(:instance) { described_class.new(config_file.path) }

  def write_config(content)
    config_file.write(content)
    config_file.rewind
  end

  describe ".instance" do
    it "returns the same instance" do
      expect(described_class.instance.object_id).to eq(described_class.instance.object_id)
    end

    it "uses the default FILE_PATH" do
      instance = described_class.instance
      expect(instance.instance_variable_get(:@path)).to eq(described_class::FILE_PATH)
    end
  end

  describe "#config" do
    context "when file exists with valid config" do
      before { write_config(YAML.dump(valid_config)) }

      it "returns the configuration hash" do
        expect(instance.config).to eq(valid_config)
      end

      it "freezes the returned config" do
        expect(instance.config).to be_frozen
      end

      it "memoizes the result" do
        first_call = instance.config
        second_call = instance.config
        expect(first_call).to equal(second_call)
      end
    end

    context "when file does not exist" do
      let(:instance) { described_class.new("non/existent/path.yml") }

      it "returns an empty hash" do
        expect(instance.config).to eq({})
      end
    end

    context "when file contains non-hash data" do
      before do
        write_config(YAML.dump([1, 2, 3]))
      end

      it "raises an error" do
        expect { instance.config }.to raise_error(/must contain a YAML hash/)
      end
    end

    context "when file contains string instead of hash" do
      before do
        write_config(YAML.dump("just a string"))
      end

      it "raises an error" do
        expect { instance.config }.to raise_error(/must contain a YAML hash/)
      end
    end

    context "when file is empty" do
      before do
        write_config("")
      end

      it "returns an empty hash" do
        expect(instance.config).to eq({})
      end
    end
  end
end
