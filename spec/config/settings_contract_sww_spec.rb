# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe SettingsContractSww do
  let(:valid_settings) do
    {
      people: {
        inactivity_block: {
          warn_after: "P1Y",
          block_after: "P1Y"
        }
      },
      invoice_runs: {
        fixed_fees: {
          membership: {

            enabled: false
          }
        }
      },
      droptours_export: {
        sftp_config: [
          {
            fachorganisation_id: 1,
            host: "sftp.example.com",
            port: 22,
            user: "testuser",
            password: "secret123",
            remote_path: "/uploads"
          }
        ]
      }
    }
  end

  subject { described_class.new.call(settings) }

  context "with valid settings" do
    let(:settings) { valid_settings }

    it { is_expected.to be_success }
  end

  context "with multiple valid SFTP configs" do
    let(:settings) do
      valid_settings.merge(
        droptours_export: {
          sftp_config: [
            {
              fachorganisation_id: 1,
              host: "sftp1.example.com",
              user: "user1",
              password: "pass1",
              remote_path: "/path1"
            },
            {
              fachorganisation_id: 2,
              host: "sftp2.example.com",
              port: 2222,
              user: "user2",
              private_key: "-----BEGIN RSA PRIVATE KEY-----",
              remote_path: "/path2"
            }
          ]
        }
      )
    end

    it { is_expected.to be_success }
  end

  context "fachorganisation_id validation" do
    context "when fachorganisation_id is missing" do
      let(:settings) do
        valid_settings.tap do |s|
          s[:droptours_export][:sftp_config][0].delete(:fachorganisation_id)
        end
      end

      it { is_expected.not_to be_success }

      it "has the correct error message" do
        expect(subject.errors.to_h[:droptours_export][:sftp_config][0][:fachorganisation_id])
          .to include("is missing")
      end
    end

    context "when fachorganisation_id is nil" do
      let(:settings) do
        valid_settings.tap do |s|
          s[:droptours_export][:sftp_config][0][:fachorganisation_id] = nil
        end
      end

      it { is_expected.not_to be_success }

      it "has the correct error message" do
        expect(subject.errors.to_h[:droptours_export][:sftp_config][0][:fachorganisation_id])
          .to include("must be filled")
      end
    end

    context "when fachorganisation_id is not an integer" do
      let(:settings) do
        valid_settings.tap do |s|
          s[:droptours_export][:sftp_config][0][:fachorganisation_id] = "not_a_number"
        end
      end

      it { is_expected.not_to be_success }

      it "has the correct error message" do
        expect(subject.errors.to_h[:droptours_export][:sftp_config][0][:fachorganisation_id])
          .to include("must be an integer")
      end
    end
  end

  context "SFTP config validation (delegated to Sftp::ConfigContract)" do
    context "when host is missing" do
      let(:settings) do
        valid_settings.tap do |s|
          s[:droptours_export][:sftp_config][0].delete(:host)
        end
      end

      it { is_expected.not_to be_success }

      it "has the correct error message" do
        expect(subject.errors.to_h[:droptours_export][:sftp_config][0][:host])
          .to include("is missing")
      end
    end
  end

  context "with errors in multiple SFTP configs" do
    let(:settings) do
      valid_settings.merge(
        droptours_export: {
          sftp_config: [
            {
              fachorganisation_id: 1,
              host: "sftp1.example.com",
              user: "",
              password: "pass1"
            },
            {
              fachorganisation_id: "not_a_number",
              host: "sftp2.example.com",
              user: "user2",
              remote_path: "/path2"
            }
          ]
        }
      )
    end

    it { is_expected.not_to be_success }

    it "has errors for both configs" do
      errors = subject.errors.to_h[:droptours_export][:sftp_config]

      expect(errors[0][:user]).to include("must be filled")
      expect(errors[1][:fachorganisation_id]).to include("must be an integer")
    end
  end
end
