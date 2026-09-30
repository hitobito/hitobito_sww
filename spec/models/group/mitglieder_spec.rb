# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Group::Mitglieder do
  let(:fachorganisation) { groups(:berner_wanderwege) }
  let(:mitglieder) { groups(:berner_mitglieder) }

  describe "droptours_export validation" do
    context "when droptours_export is enabled" do
      it "with upload config for the fachorganisation is valid" do
        allow(Export::DroptoursUploadConfig).to receive(:instance)
          .and_return(instance_double(Export::DroptoursUploadConfig,
            config: {fachorganisation.id => {}}))

        mitglieder.droptours_export = true

        expect(mitglieder).to be_valid
      end

      it "without upload config for the fachorganisation is invalid" do
        allow(Export::DroptoursUploadConfig).to receive(:instance)
          .and_return(instance_double(
            Export::DroptoursUploadConfig, config: {}
          ))

        mitglieder.droptours_export = true

        expect(mitglieder).not_to be_valid
        expect(mitglieder.errors[:droptours_export].join).to match("SFTP-Konfiguration")
      end
    end

    context "when droptours_export is disabled" do
      it "is valid without upload config" do
        allow(Export::DroptoursUploadConfig).to receive(:instance)
          .and_return(instance_double(Export::DroptoursUploadConfig,
            config: {}))

        mitglieder.droptours_export = false

        expect(mitglieder).to be_valid
      end
    end
  end
end
