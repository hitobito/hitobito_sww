# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Export::Pdf::Invoice do
  let(:invoice) do
    invoices(:invoice).tap do |i|
      i.payment_slip = :qr
      i.payee = "Puzzle\nBelpstrasse 37\n3007 Bern" 
      i.iban = 'CH93 0076 2011 6238 5295 7'
    end
  end

  let!(:invoice_config) do
    invoice.group.layer_group.create_invoice_config!(payee: "Puzzle\nBelpstrasse 37\n3007 Bern",
                                                     iban: 'CH93 0076 2011 6238 5295 7')
  end

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
      invoice.group.letter_address_position = :left
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      invoice_text = [[346, 721, "Mitgliederausweis"],
                      [346, 710, "42421"],
                      [346, 699, "Bob Foo"],
                      [511, 721, "Gültig bis"],
                      [517, 710, "10.2022"],
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
                      [14, 276, "Empfangsschein"],
                      [14, 251, "Konto / Zahlbar an"],
                      [14, 239, "CH93 0076 2011 6238 5295 7"],
                      [14, 228, "Puzzle"],
                      [14, 216, "Belpstrasse 37"],
                      [14, 205, "3007 Bern"],
                      [14, 173, "Zahlbar durch"],
                      [14, 161, "Max Muster"],
                      [14, 150, "Belpstrasse 37"],
                      [14, 138, "3007 Bern"],
                      [14, 89, "Währung"],
                      [71, 89, "Betrag"],
                      [14, 78, "CHF"],
                      [105, 39, "Annahmestelle"],
                      [190, 276, "Zahlteil"],
                      [190, 89, "Währung"],
                      [247, 89, "Betrag"],
                      [190, 78, "CHF"],
                      [346, 278, "Konto / Zahlbar an"],
                      [346, 266, "CH93 0076 2011 6238 5295 7"],
                      [346, 255, "Puzzle"],
                      [346, 243, "Belpstrasse 37"],
                      [346, 232, "3007 Bern"],
                      [346, 211, "Referenznummer"],
                      [346, 200, "00 00376 80338 90000 00000 00021"],
                      [346, 178, "Zahlbar durch"],
                      [346, 167, "Max Muster"],
                      [346, 155, "Belpstrasse 37"],
                      [346, 144, "3007 Bern"]]

      expect(text_with_position).to eq(invoice_text)
    end


    it 'renders receiver address' do
      expect(text_with_position).to include([57, 688, "Max Muster"],
                                            [57, 676, "Belpstrasse 37"],
                                            [57, 665, "3007 Bern"])
    end
  end

  context 'with separators true' do
    before { invoice_config.update!(separators: true) }

    it 'renders separators' do
      pdf = Prawn::Document.new(page_size: 'A4',
                                page_layout: :portrait,
                                margin: 2.cm)

      slip = ::Export::Pdf::Invoice::PaymentSlipQr.new(pdf, invoice, {})
      expect(::Export::Pdf::Invoice::PaymentSlipQr).to receive(:new).and_return(slip)
      expect(slip).to receive(:separators_without_configuration)
      subject
    end

    it 'renders everything else regardless' do
      expect(text_with_position).to eq([[406, 530, "Rechnungsdatum: 15.06.2022"],
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
                                        [14, 276, "Empfangsschein"],
                                        [14, 251, "Konto / Zahlbar an"],
                                        [14, 239, "CH93 0076 2011 6238 5295 7"],
                                        [14, 228, "Puzzle"],
                                        [14, 216, "Belpstrasse 37"],
                                        [14, 205, "3007 Bern"],
                                        [14, 173, "Zahlbar durch"],
                                        [14, 161, "Max Muster"],
                                        [14, 150, "Belpstrasse 37"],
                                        [14, 138, "3007 Bern"],
                                        [14, 89, "Währung"],
                                        [71, 89, "Betrag"],
                                        [14, 78, "CHF"],
                                        [105, 39, "Annahmestelle"],
                                        [190, 276, "Zahlteil"],
                                        [190, 89, "Währung"],
                                        [247, 89, "Betrag"],
                                        [190, 78, "CHF"],
                                        [346, 278, "Konto / Zahlbar an"],
                                        [346, 266, "CH93 0076 2011 6238 5295 7"],
                                        [346, 255, "Puzzle"],
                                        [346, 243, "Belpstrasse 37"],
                                        [346, 232, "3007 Bern"],
                                        [346, 211, "Referenznummer"],
                                        [346, 200, "00 00376 80338 90000 00000 00021"],
                                        [346, 178, "Zahlbar durch"],
                                        [346, 167, "Max Muster"],
                                        [346, 155, "Belpstrasse 37"],
                                        [346, 144, "3007 Bern"]])
    end

    it 'renders total when hide_total=false' do
      InvoiceItem.create(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.hide_total = false
      expect(rows_at_position(441)).to eq [
        [431, 441, "Gesamtbetrag"],
        [501, 441, "11.00 CHF"]
      ]
      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      InvoiceItem.create(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.hide_total = true
      expect(rows_at_position(435)).to eq [
        [431, 435, "Subtotal"],
        [501, 435, "11.00 CHF"]
      ]
      expect(rows_at_position(415)).to eq [[431, 415, "Spende"]]
      expect(rows_at_position(396)).to eq [[431, 396, "Gesamtbetrag"]]
    end
  end

  context 'with separators false' do
    before { invoice_config.update!(separators: false) }

    it 'does not render separators' do
      pdf = Prawn::Document.new(page_size: 'A4',
                                page_layout: :portrait,
                                margin: 2.cm)

      slip = ::Export::Pdf::Invoice::PaymentSlipQr.new(pdf, invoice, {})
      expect(::Export::Pdf::Invoice::PaymentSlipQr).to receive(:new).and_return(slip)
      expect(slip).to_not receive(:separators_without_configuration)
      subject
    end

    it 'renders everything else regardless' do
      expect(text_with_position).to eq([[406, 530, "Rechnungsdatum: 15.06.2022"],
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
                                        [14, 276, "Empfangsschein"],
                                        [14, 251, "Konto / Zahlbar an"],
                                        [14, 239, "CH93 0076 2011 6238 5295 7"],
                                        [14, 228, "Puzzle"],
                                        [14, 216, "Belpstrasse 37"],
                                        [14, 205, "3007 Bern"],
                                        [14, 173, "Zahlbar durch"],
                                        [14, 161, "Max Muster"],
                                        [14, 150, "Belpstrasse 37"],
                                        [14, 138, "3007 Bern"],
                                        [14, 89, "Währung"],
                                        [71, 89, "Betrag"],
                                        [14, 78, "CHF"],
                                        [105, 39, "Annahmestelle"],
                                        [190, 276, "Zahlteil"],
                                        [190, 89, "Währung"],
                                        [247, 89, "Betrag"],
                                        [190, 78, "CHF"],
                                        [346, 278, "Konto / Zahlbar an"],
                                        [346, 266, "CH93 0076 2011 6238 5295 7"],
                                        [346, 255, "Puzzle"],
                                        [346, 243, "Belpstrasse 37"],
                                        [346, 232, "3007 Bern"],
                                        [346, 211, "Referenznummer"],
                                        [346, 200, "00 00376 80338 90000 00000 00021"],
                                        [346, 178, "Zahlbar durch"],
                                        [346, 167, "Max Muster"],
                                        [346, 155, "Belpstrasse 37"],
                                        [346, 144, "3007 Bern"]])
    end

    it 'renders total when hide_total=false' do
      InvoiceItem.create(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.hide_total = false
      expect(rows_at_position(441)).to eq [
        [431, 441, "Gesamtbetrag"],
        [501, 441, "11.00 CHF"]
      ]
      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      InvoiceItem.create(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.hide_total = true
      expect(rows_at_position(435)).to eq [
        [431, 435, "Subtotal"],
        [501, 435, "11.00 CHF"]
      ]
      expect(rows_at_position(415)).to eq [[431, 415, "Spende"]]
      expect(rows_at_position(396)).to eq [[431, 396, "Gesamtbetrag"]]
    end
  end

  context 'rendered right' do
    before do
      invoice.group.letter_address_position = :right
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      expect(text_with_position).to eq([[57, 721, "Mitgliederausweis"],
                                        [57, 710, "42421"],
                                        [57, 699, "Bob Foo"],
                                        [222, 721, "Gültig bis"],
                                        [227, 710, "10.2022"],
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
                                        [14, 276, "Empfangsschein"],
                                        [14, 251, "Konto / Zahlbar an"],
                                        [14, 239, "CH93 0076 2011 6238 5295 7"],
                                        [14, 228, "Puzzle"],
                                        [14, 216, "Belpstrasse 37"],
                                        [14, 205, "3007 Bern"],
                                        [14, 173, "Zahlbar durch"],
                                        [14, 161, "Max Muster"],
                                        [14, 150, "Belpstrasse 37"],
                                        [14, 138, "3007 Bern"],
                                        [14, 89, "Währung"],
                                        [71, 89, "Betrag"],
                                        [14, 78, "CHF"],
                                        [105, 39, "Annahmestelle"],
                                        [190, 276, "Zahlteil"],
                                        [190, 89, "Währung"],
                                        [247, 89, "Betrag"],
                                        [190, 78, "CHF"],
                                        [346, 278, "Konto / Zahlbar an"],
                                        [346, 266, "CH93 0076 2011 6238 5295 7"],
                                        [346, 255, "Puzzle"],
                                        [346, 243, "Belpstrasse 37"],
                                        [346, 232, "3007 Bern"],
                                        [346, 211, "Referenznummer"],
                                        [346, 200, "00 00376 80338 90000 00000 00021"],
                                        [346, 178, "Zahlbar durch"],
                                        [346, 167, "Max Muster"],
                                        [346, 155, "Belpstrasse 37"],
                                        [346, 144, "3007 Bern"]])
    end

    it 'renders receiver address' do
      expect(text_with_position).to include([347, 688, "Max Muster"],
                                            [347, 676, "Belpstrasse 37"],
                                            [347, 665, "3007 Bern"])
    end
  end

  context 'rendered at custom position' do
    before do
      invoice.group.letter_left_address_position = 3 # 3.cm = 85
      invoice.group.letter_top_address_position = 5
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      expect(text_with_position).to eq([[346, 721, "Mitgliederausweis"],
                                        [346, 710, "42421"],
                                        [346, 699, "Bob Foo"],
                                        [511, 721, "Gültig bis"],
                                        [517, 710, "10.2022"],
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
                                        [14, 276, "Empfangsschein"],
                                        [14, 251, "Konto / Zahlbar an"],
                                        [14, 239, "CH93 0076 2011 6238 5295 7"],
                                        [14, 228, "Puzzle"],
                                        [14, 216, "Belpstrasse 37"],
                                        [14, 205, "3007 Bern"],
                                        [14, 173, "Zahlbar durch"],
                                        [14, 161, "Max Muster"],
                                        [14, 150, "Belpstrasse 37"],
                                        [14, 138, "3007 Bern"],
                                        [14, 89, "Währung"],
                                        [71, 89, "Betrag"],
                                        [14, 78, "CHF"],
                                        [105, 39, "Annahmestelle"],
                                        [190, 276, "Zahlteil"],
                                        [190, 89, "Währung"],
                                        [247, 89, "Betrag"],
                                        [190, 78, "CHF"],
                                        [346, 278, "Konto / Zahlbar an"],
                                        [346, 266, "CH93 0076 2011 6238 5295 7"],
                                        [346, 255, "Puzzle"],
                                        [346, 243, "Belpstrasse 37"],
                                        [346, 232, "3007 Bern"],
                                        [346, 211, "Referenznummer"],
                                        [346, 200, "00 00376 80338 90000 00000 00021"],
                                        [346, 178, "Zahlbar durch"],
                                        [346, 167, "Max Muster"],
                                        [346, 155, "Belpstrasse 37"],
                                        [346, 144, "3007 Bern"]])
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
      expect(rows_at_position(441)).to eq [
        [431, 441, "Gesamtbetrag"],
        [501, 441, "11.00 CHF"]
      ]
      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      invoice.hide_total = true
      expect(rows_at_position(435)).to eq [
        [431, 435, "Subtotal"],
        [501, 435, "11.00 CHF"]
      ]
      expect(rows_at_position(415)).to eq [[431, 415, "Spende"]]
      expect(rows_at_position(396)).to eq [[431, 396, "Gesamtbetrag"]]
    end
  end
end
