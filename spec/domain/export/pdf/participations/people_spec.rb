# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Pdf::Participations::People do
  let(:runner) { Export::Pdf::Participations::Runner.new }
  let(:people) { [participation] }
  let(:group) { nil }

  subject { described_class.new(runner.send(:setup_pdf), people, group) }

  it 'builds upon people-list export' do
    is_expected.to be_a Export::Pdf::List::People
  end

  it 'has a header for the "additional information"-column' do
    expect(subject.send(:table_header)).to include 'Bemerkungen'
  end

  let(:participation) { Fabricate(:event_participation, additional_information: comment) }
  let(:comment) { "Mag Blørbaël, aber keine Rüebli, allergisch auf Menschen" }

  it 'displays the "additional information"' do
    expect(subject.send(:person_row, participation)).to include comment
  end
end
