# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe People::Merger do
  let!(:person) { Fabricate(:person) }
  let!(:duplicate) { Fabricate(:person_with_address_and_phone) }
  let(:actor) { people(:zuercher_wanderer) }

  let(:merger) { described_class.new(@source.reload, @target.reload, actor) }

  context "merge people" do
    before do
      @source = duplicate
      @target = person
    end

    it "merges manual_member_number" do
      duplicate.update!(manual_member_number: 123)
      orig_manual_member_number = duplicate.manual_member_number

      expect do
        merger.merge!
      end.to change(Person, :count).by(-1)

      person.reload
      expect(person.manual_member_number).to eq orig_manual_member_number
    end

    it "adds source manual_member_number to version" do
      duplicate.update!(manual_member_number: 234561)
      merger.merge!
      expect(person.versions.first.object_changes.to_s).to include("234561")
    end
  end
end
