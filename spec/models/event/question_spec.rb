# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Event::Question do
  describe "::list" do
    let(:event) { Fabricate(:event, groups: [groups(:schweizer_wanderwege)]) }

    it "orders by id not by question" do
      Fabricate(:event_question, event:, question: "2. we come first")
      Fabricate(:event_question, event:, question: "1. we are second")
      expect(event.questions.list.map(&:question)).to eq [
        "2. we come first",
        "1. we are second"
      ]
    end
  end
end
