# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Export::Pdf::Participations do
  it "supports the common interface" do
    expect(described_class).to respond_to(:render)
  end
end

describe Export::Pdf::Participations::Runner do
  let(:sections) { described_class.new.send(:sections) }

  it "uses a custom sections for people list" do
    expect(sections).to match_array [Export::Pdf::Participations::Header,
      Export::Pdf::Participations::People]
  end
end
