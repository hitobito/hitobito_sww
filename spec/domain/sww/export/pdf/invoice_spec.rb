# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Export::Pdf::Invoice do
  let(:invoice) { invoices(:invoice) }

  subject do
    invoice.update!(issued_at: Date.parse('2022-06-15'), due_at: Date.parse('2022-08-01'))
    pdf = described_class.render(invoice, payment_slip: true, articles: true)
    PDF::Inspector::Text.analyze(pdf)
  end

  def text_with_position
    subject.positions.each_with_index.collect do |p, i|
      p.collect(&:round) + [subject.show_text[i]]
    end
  end

  it 'renders receiver address to the left' do
    expect(text_with_position).to include([57, 687, "Max Muster"],
                                          [57, 676, "Belpstrasse 37"],
                                          [57, 664, "3007 Bern"])
  end

  it 'renders invoice information to the right' do
    expect(text_with_position).to include([347, 649, "Rechnungsdatum:"],
                                          [448, 649, "15.06.2022"])
  end

  it 'renders invoice number as column label' do
    expect(text_with_position).to include([57, 525, "Rechnungsnummer: 636980692-2"])
  end

  it 'renders invoice due at bellow articles table' do
    expect(text_with_position).to include([57, 497, "Fällig bis:      01.08.2022"])
  end
end
