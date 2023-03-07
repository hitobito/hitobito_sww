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

  def rows_at_position(pos)
    text_with_position.select { _2 == pos }
  end

  context 'rendered left' do
    before do
      invoice.group.settings(:messages_letter).address_position = :left
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      invoice_text = [[346, 721, "Mitgliederausweis"],
                      [346, 710, "42421"],
                      [346, 698, "Bob Foo"],
                      [511, 710, "Gültig bis"],
                      [517, 698, "10.2022"],
                      [406, 530, "Rechnungsdatum: 15.06.2022"],
                      [57, 688, "Max Muster"],
                      [57, 676, "Belpstrasse 37"],
                      [57, 665, "3007 Bern"],
                      [57, 530, "Invoice"],
                      [57, 497, "Rechnungsnummer: 636980692-2"],
                      [363, 497, "Anzahl"],
                      [419, 497, "Preis"],
                      [464, 497, "Betrag"],
                      [515, 497, "MwSt."],
                      [436, 484, "Zwischenbetrag"],
                      [505, 484, "0.00 CHF"],
                      [436, 467, "Gesamtbetrag"],
                      [505, 467, "0.00 CHF"],
                      [57, 468, "Fällig bis:      01.08.2022"],
                      [72, 171, "636980692-4"],
                      [252, 171, "636980692-4"],
                      [352, 196, "00 00376 80338 90000 00000 00021"],
                      [7, 116, "00 00376 80338 90000 00000 00021"],
                      [7, 103, "Max Muster"],
                      [7, 87, "Belpstrasse 37"],
                      [7, 71, "3007 Bern"],
                      [352, 147, "Max Muster"],
                      [352, 131, "Belpstrasse 37"],
                      [352, 115, "3007 Bern"],
                      [220, 45, "042>000063698069200000000000022+ 636980692000004>"]]
      expect(text_with_position).to eq(invoice_text)
    end

    it 'renders receiver address' do
      expect(text_with_position).to include([57, 688, "Max Muster"],
                                            [57, 676, "Belpstrasse 37"],
                                            [57, 665, "3007 Bern"])
    end
  end

  context 'rendered right' do
    before do
      invoice.group.settings(:messages_letter).address_position = :right
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      expect(text_with_position).to eq([[57, 721, "Mitgliederausweis"],
                                        [57, 710, "42421"],
                                        [57, 698, "Bob Foo"],
                                        [222, 710, "Gültig bis"],
                                        [227, 698, "10.2022"],
                                        [406, 530, "Rechnungsdatum: 15.06.2022"],
                                        [347, 688, "Max Muster"],
                                        [347, 676, "Belpstrasse 37"],
                                        [347, 665, "3007 Bern"],
                                        [57, 530, "Invoice"],
                                        [57, 497, "Rechnungsnummer: 636980692-2"],
                                        [363, 497, "Anzahl"],
                                        [419, 497, "Preis"],
                                        [464, 497, "Betrag"],
                                        [515, 497, "MwSt."],
                                        [436, 484, "Zwischenbetrag"],
                                        [505, 484, "0.00 CHF"],
                                        [436, 467, "Gesamtbetrag"],
                                        [505, 467, "0.00 CHF"],
                                        [57, 468, "Fällig bis:      01.08.2022"],
                                        [72, 171, "636980692-4"],
                                        [252, 171, "636980692-4"],
                                        [352, 196, "00 00376 80338 90000 00000 00021"],
                                        [7, 116, "00 00376 80338 90000 00000 00021"],
                                        [7, 103, "Max Muster"],
                                        [7, 87, "Belpstrasse 37"],
                                        [7, 71, "3007 Bern"],
                                        [352, 147, "Max Muster"],
                                        [352, 131, "Belpstrasse 37"],
                                        [352, 115, "3007 Bern"],
                                        [220, 45, "042>000063698069200000000000022+ 636980692000004>"]])
    end

    it 'renders receiver address' do
      expect(text_with_position).to include([347, 688, "Max Muster"],
                                            [347, 676, "Belpstrasse 37"],
                                            [347, 665, "3007 Bern"])
    end
  end

  context 'rendered at custom position' do
    before do
      invoice.group.settings(:messages_letter).left_address_position = 3 # 3.cm = 85
      invoice.group.settings(:messages_letter).top_address_position = 5
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      expect(text_with_position).to eq([[346, 721, "Mitgliederausweis"],
                                        [346, 710, "42421"],
                                        [346, 698, "Bob Foo"],
                                        [511, 710, "Gültig bis"],
                                        [517, 698, "10.2022"],
                                        [406, 530, "Rechnungsdatum: 15.06.2022"],
                                        [85, 691, "Max Muster"],
                                        [85, 679, "Belpstrasse 37"],
                                        [85, 668, "3007 Bern"],
                                        [57, 530, "Invoice"],
                                        [57, 497, "Rechnungsnummer: 636980692-2"],
                                        [363, 497, "Anzahl"],
                                        [419, 497, "Preis"],
                                        [464, 497, "Betrag"],
                                        [515, 497, "MwSt."],
                                        [436, 484, "Zwischenbetrag"],
                                        [505, 484, "0.00 CHF"],
                                        [436, 467, "Gesamtbetrag"],
                                        [505, 467, "0.00 CHF"],
                                        [57, 468, "Fällig bis:      01.08.2022"],
                                        [72, 171, "636980692-4"],
                                        [252, 171, "636980692-4"],
                                        [352, 196, "00 00376 80338 90000 00000 00021"],
                                        [7, 116, "00 00376 80338 90000 00000 00021"],
                                        [7, 103, "Max Muster"],
                                        [7, 87, "Belpstrasse 37"],
                                        [7, 71, "3007 Bern"],
                                        [352, 147, "Max Muster"],
                                        [352, 131, "Belpstrasse 37"],
                                        [352, 115, "3007 Bern"],
                                        [220, 45, "042>000063698069200000000000022+ 636980692000004>"]])
    end

    it 'renders receiver address' do
      expect(text_with_position).to include([85, 691, "Max Muster"],
                                            [85, 679, "Belpstrasse 37"],
                                            [85, 668, "3007 Bern"])
    end
  end


  it 'renders invoice information to the right' do
    expect(text_with_position).to include([406, 530, "Rechnungsdatum: 15.06.2022"])
  end

  it 'renders invoice number as column label' do
    expect(text_with_position).to include([57, 497, "Rechnungsnummer: 636980692-2"])
  end

  it 'renders invoice due at below articles table' do
    expect(text_with_position).to include([57, 468, "Fällig bis:      01.08.2022"])
  end

  context do
    let(:invoice) do
      invoices(:invoice).tap { InvoiceItem.create(invoice: _1, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10) }
    end

    it 'renders total when hide_total=false' do
      invoice.hide_total = false
      expect(rows_at_position(454)).to eq [
        [431, 454, "Gesamtbetrag"],
        [501, 454, "11.00 CHF"]
      ]
      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      invoice.hide_total = true
      expect(rows_at_position(454)).to eq [
        [431, 454, "Subtotal"],
        [501, 454, "11.00 CHF"]
      ]
      expect(rows_at_position(434)).to eq [[431, 434, "Spende"]]
      expect(rows_at_position(415)).to eq [[431, 415, "Gesamtbetrag"]]
    end
  end
end
