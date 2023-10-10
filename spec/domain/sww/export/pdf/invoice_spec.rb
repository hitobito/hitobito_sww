# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Export::Pdf::Invoice do
  include PdfHelpers

  let(:invoice) do
    invoices(:invoice).tap do |i|
      i.update!(
        payment_slip: :qr,
        payee: "Puzzle\nBelpstrasse 37\n3007 Bern",
        iban: 'CH93 0076 2011 6238 5295 7',
        issued_at: Date.parse('2022-06-15'),
        due_at: Date.parse('2022-08-01')
      )
    end
  end

  let(:invoice_config) do
    invoice.invoice_config
  end

  let(:pdf) { described_class.render(invoice, payment_slip: true, articles: true) }

  subject { PDF::Inspector::Text.analyze(pdf) }

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
                      [404, 484, "Zwischenbetrag"],
                      [505, 484, "0.00 CHF"],
                      [404, 467, "Gesamtbetrag"],
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

      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
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
      invoice_text = [[406, 530, "Rechnungsdatum: 15.06.2022"],
                      [57, 688, "Max Muster"],
                      [57, 676, "Belpstrasse 37"],
                      [57, 665, "3007 Bern"],
                      [57, 530, "Invoice"],
                      [57, 497, "Rechnungsnummer: 636980692-2"],
                      [363, 497, "Anzahl"],
                      [419, 497, "Preis"],
                      [464, 497, "Betrag"],
                      [515, 497, "MwSt."],
                      [404, 484, "Zwischenbetrag"],
                      [505, 484, "0.00 CHF"],
                      [404, 467, "Gesamtbetrag"],
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

      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
    end

    it 'renders total when hide_total=false' do
      InvoiceItem.create!(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: false)
      invoice.reload.recalculate!
      expect(rows_at_position(441)).to eq [
        [400, 441, "Gesamtbetrag"],
        [501, 441, "11.00 CHF"]
      ]
      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      InvoiceItem.create!(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: true)
      invoice.reload.recalculate!
      expect(rows_at_position(457)).to eq [
        [400, 457, "Subtotal"],
        [501, 457, "11.00 CHF"]
      ]
      expect(rows_at_position(443)).to eq [[400, 443, "Spende"]]
      expect(rows_at_position(427)).to eq [[400, 427, "Gesamtbetrag"]]
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
      invoice_text = [[406, 530, "Rechnungsdatum: 15.06.2022"],
                      [57, 688, "Max Muster"],
                      [57, 676, "Belpstrasse 37"],
                      [57, 665, "3007 Bern"],
                      [57, 530, "Invoice"],
                      [57, 497, "Rechnungsnummer: 636980692-2"],
                      [363, 497, "Anzahl"],
                      [419, 497, "Preis"],
                      [464, 497, "Betrag"],
                      [515, 497, "MwSt."],
                      [404, 484, "Zwischenbetrag"],
                      [505, 484, "0.00 CHF"],
                      [404, 467, "Gesamtbetrag"],
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

      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
    end

    it 'renders total when hide_total=false' do
      InvoiceItem.create!(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: false)
      invoice.reload.recalculate!
      expect(rows_at_position(441)).to eq [
        [400, 441, "Gesamtbetrag"],
        [501, 441, "11.00 CHF"]
      ]
      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      InvoiceItem.create!(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: true)
      invoice.reload.recalculate!
      expect(rows_at_position(457)).to eq [
        [400, 457, "Subtotal"],
        [501, 457, "11.00 CHF"]
      ]
      expect(rows_at_position(443)).to eq [[400, 443, "Spende"]]
      expect(rows_at_position(427)).to eq [[400, 427, "Gesamtbetrag"]]
    end
  end

  context 'rendered right' do
    before do
      invoice.group.letter_address_position = :right
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      invoice_text = [[57, 721, "Mitgliederausweis"],
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
                      [404, 484, "Zwischenbetrag"],
                      [505, 484, "0.00 CHF"],
                      [404, 467, "Gesamtbetrag"],
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

      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
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
      invoice_text = [[346, 721, "Mitgliederausweis"],
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
                      [404, 484, "Zwischenbetrag"],
                      [505, 484, "0.00 CHF"],
                      [404, 467, "Gesamtbetrag"],
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

      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
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
      invoices(:invoice).tap do |i|
        i.update!(
          payment_slip: :qr,
          payee: "Puzzle\nBelpstrasse 37\n3007 Bern",
          iban: 'CH93 0076 2011 6238 5295 7',
          issued_at: Date.parse('2022-06-15'),
          due_at: Date.parse('2022-08-01')
        )
        InvoiceItem.create(invoice: i, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
        i.reload.recalculate!
      end
    end

    context 'with hide_total=false' do
      before { invoice.update!(hide_total: false) }

      it 'renders total' do
        expect(rows_at_position(441)).to eq [
          [400, 441, "Gesamtbetrag"],
          [501, 441, "11.00 CHF"]
        ]
        full_text = subject.show_text.join("\n")
        expect(full_text).not_to include("Subtotal")
        expect(full_text).not_to include("Spende")
      end

      it 'renders partial payments' do
        invoice.payments.build(amount: 5, received_at: Time.zone.yesterday)
        invoice.payments.build(amount: 3, received_at: Time.zone.yesterday)
        invoice.save!
        invoice.reload.recalculate!
        invoice_text = [[406, 530, "Rechnungsdatum: 15.06.2022"],
                        [57, 688, "Max Muster"],
                        [57, 676, "Belpstrasse 37"],
                        [57, 665, "3007 Bern"],
                        [57, 530, "Invoice"],
                        [57, 497, "Rechnungsnummer: 636980692-2"],
                        [363, 497, "Anzahl"],
                        [419, 497, "Preis"],
                        [464, 497, "Betrag"],
                        [515, 497, "MwSt."],
                        [57, 484, "dings"],
                        [383, 484, "1"],
                        [418, 484, "10.00"],
                        [468, 484, "10.00"],
                        [513, 484, "10.0 %"],
                        [400, 470, "Zwischenbetrag"],
                        [501, 470, "10.00 CHF"],
                        [400, 457, "MwSt."],
                        [505, 457, "1.00 CHF"],
                        [400, 444, "Gesamtbetrag"],
                        [501, 444, "11.00 CHF"],
                        [400, 430, "Eingegangene Zahlung"],
                        [505, 430, "5.00 CHF"],
                        [400, 417, "Eingegangene Zahlung"],
                        [505, 417, "3.00 CHF"],
                        [400, 401, "Offener Betrag"],
                        [505, 401, "3.00 CHF"],
                        [57, 401, "Fällig bis:      01.08.2022"],
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
                        [71, 78, "3.00"],
                        [105, 39, "Annahmestelle"],
                        [190, 276, "Zahlteil"],
                        [190, 89, "Währung"],
                        [247, 89, "Betrag"],
                        [190, 78, "CHF"],
                        [247, 78, "3.00"],
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

        text_with_position.each_with_index do |l, i|
          expect(l).to eq(invoice_text[i])
        end
      end
    end

    context 'with hide_total=true' do
      before { invoice.update!(hide_total: true) }
      it 'renders subtotal and donation row' do
        expect(rows_at_position(457)).to eq [
          [400, 457, "Subtotal"],
          [501, 457, "11.00 CHF"]
        ]
        expect(rows_at_position(443)).to eq [[400, 443, "Spende"]]
        expect(rows_at_position(427)).to eq [[400, 427, "Gesamtbetrag"]]
      end

      it 'renders partial payments' do
        invoice.payments.build(amount: 5, received_at: Time.zone.yesterday)
        invoice.payments.build(amount: 3, received_at: Time.zone.yesterday)
        invoice.save!
        invoice.reload.recalculate!
        invoice_text = [[406, 530, "Rechnungsdatum: 15.06.2022"],
                        [57, 688, "Max Muster"],
                        [57, 676, "Belpstrasse 37"],
                        [57, 665, "3007 Bern"],
                        [57, 530, "Invoice"],
                        [57, 497, "Rechnungsnummer: 636980692-2"],
                        [363, 497, "Anzahl"],
                        [419, 497, "Preis"],
                        [464, 497, "Betrag"],
                        [515, 497, "MwSt."],
                        [57, 484, "dings"],
                        [383, 484, "1"],
                        [418, 484, "10.00"],
                        [468, 484, "10.00"],
                        [513, 484, "10.0 %"],
                        [400, 470, "Zwischenbetrag"],
                        [501, 470, "10.00 CHF"],
                        [400, 457, "MwSt."],
                        [505, 457, "1.00 CHF"],
                        [400, 444, "Eingegangene Zahlung"],
                        [505, 444, "5.00 CHF"],
                        [400, 430, "Eingegangene Zahlung"],
                        [505, 430, "3.00 CHF"],
                        [400, 417, "Offener Betrag"],
                        [505, 417, "3.00 CHF"],
                        [400, 404, "Spende"],
                        [400, 387, "Gesamtbetrag"],
                        [57, 388, "Fällig bis:      01.08.2022"],
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

        text_with_position.each_with_index do |l, i|
          expect(l).to eq(invoice_text[i])
        end
      end
    end
  end

  context 'logo' do
    before { invoice.invoice_config.separators = false }

    context 'when invoice_config has no logo' do
      before do
        expect(invoice.invoice_config.logo).not_to be_attached
      end

      [:disabled, :left, :right, :above_payment_slip].each do |position|
        it "with logo_position=#{position} it does not render logo" do
          invoice.invoice_config.update(logo_position: position)
          expect(image_positions).to have(1).item # only qr code
        end
      end
    end

    context 'when invoice_config has a logo' do
      before do
        invoice.invoice_config.logo.attach fixture_file_upload('images/logo.png')
        expect(invoice.invoice_config.logo).to be_attached
      end

      it 'with logo_position=disabled it does not render logo' do
        invoice.invoice_config.update(logo_position: :disabled)
        expect(image_positions).to have(1).item # only qr code
      end

      it 'with logo_position=left it renders logo on the left' do
        invoice.invoice_config.update(logo_position: :left)
        expect(image_positions).to have(2).items # logo and qr code
        expect(image_positions.first).to match(
          displayed_height: 18_912.75561,
          displayed_width: 108_763.38,
          height: 417,
          width: 1000,
          x: 56.69291,
          y: 739.84276
        )
      end

      it 'with logo_position=right it renders logo on the right' do
        invoice.invoice_config.update(logo_position: :right)
        expect(image_positions).to have(2).items # logo and qr code
        expect(image_positions.first).to match(
          displayed_height: 18_912.75561,
          displayed_width: 108_763.38,
          height: 417,
          width: 1000,
          x: 429.8237,
          y: 739.84276
        )
      end

      it 'with logo_position=above_payment_slip it renders logo above the payment slip' do
        invoice.invoice_config.update(logo_position: :above_payment_slip)
        expect(image_positions).to have(2).items # logo and qr code
        expect(image_positions.first).to match(
          displayed_height: 18_912.75561,
          displayed_width: 108_763.38,
          height: 417,
          width: 1000,
          x: 56.69291,
          y: 314.64567
        )
      end
    end
  end
end
