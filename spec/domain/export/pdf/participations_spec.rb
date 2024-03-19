# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Pdf::Participations do
  it 'supports the common interface' do
    expect(described_class).to respond_to(:render)
  end
end

describe Export::Pdf::Participations::Runner do
  let(:pdf) { described_class.new.send(:setup_pdf) }
  let(:sections) { described_class.new.send(:sections) }

  it 'renders things in landscape-orientation' do
    expect(pdf.renderer.state.page.layout).to eq :landscape
  end

  it 'uses the standard header' do
    expect(sections).to include Export::Pdf::List::Header
  end

  it 'uses a custom section for the people-list' do
    expect(sections).to include Export::Pdf::Participations::People
  end
end
