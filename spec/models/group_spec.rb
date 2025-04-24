# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Group do
  let(:group) { groups(:schweizer_wanderwege) }

  include_examples 'group types'

  describe "#validations" do
    before do
      allow(Truemail).to receive(:valid?).and_call_original
    end

    it "event_sender_email is valid when email" do
      group.event_sender_email = "validemail@hitobito.ch"
      expect(group).to be_valid
    end

    it "event_sender_email is invalid when no email" do
      group.event_sender_email = "nomailformat"
      expect(group).not_to be_valid
    end
  end
end
