# frozen_string_literal: true

#  Copyright (c) 2012-2024, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Export::Pdf::Invoice do
  include PdfHelpers

  let(:invoice) do
    invoices(:invoice).tap do |i|
      i.update!(
        payment_slip: :qr,
        payee: "Puzzle\nBelpstrasse 37\n3007 Bern",
        iban: "CH93 0076 2011 6238 5295 7",
        issued_at: Date.parse("2022-06-15"),
        due_at: Date.parse("2022-08-01")
      )
    end
  end

  let(:invoice_config) do
    invoice.invoice_config
  end

  let(:pdf) { described_class.render(invoice, payment_slip: true, articles: true, reminders: true) }

  subject { PDF::Inspector::Text.analyze(pdf) }

  before { invoice.invoice_config.update!(separators: false) }

  def rows_at_position(pos)
    text_with_position.select { _2 == pos }
  end

  def rows_with_text(text)
    text_with_position.select { |x, y, content| content == text }
  end

  it "is a SWW::Export::Pdf::Invoice" do
    expect(described_class.ancestors).to include(Sww::Export::Pdf::Invoice)
  end

  context "logo" do
    context "when invoice_config has no logo" do
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

    context "when invoice_config has a logo" do
      before do
        invoice.invoice_config.logo.attach fixture_file_upload("images/logo.png")
        expect(invoice.invoice_config.logo).to be_attached
      end

      it "with logo_position=disabled it does not render logo" do
        invoice.invoice_config.update(logo_position: :disabled)
        expect(image_positions).to have(1).item # only qr code
      end

      it "with logo_position=left it renders logo on the left" do
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

      it "with logo_position=right it renders logo on the right" do
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

      it "with logo_position=above_payment_slip it renders logo above the payment slip" do
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

  context "rendered left" do
    before do
      invoice.group.letter_address_position = :left
      invoice.group.save!
    end

    it "renders membership_card when true" do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse("2022-10-01"))
      membership_card = [
        [346, 721, "Mitgliederausweis"],
        [346, 710, "42421"],
        [346, 699, "Bob Foo"],
        [511, 721, "Gültig bis"],
        [517, 710, "10.2022"]
      ]

      expect(text_with_position).to include(*membership_card)
    end

    it "does not render membership card when invoice has reminder" do
      invoice.update!(membership_card: true, membership_expires_on: Date.new(2022, 1, 1), due_at: 10.days.ago, state: "reminded")
      Fabricate(:payment_reminder, invoice: invoice, due_at: 3.day.ago, created_at: 5.days.ago)

      expect(text_with_position).not_to include([346, 721, "Mitgliederausweis"])
    end

    it "renders receiver address" do
      expect(text_with_position).to include(
        [57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"]
      )
    end
  end

  context "with separators true" do
    before { invoice_config.update!(separators: true) }

    it "renders separators" do
      pdf = Prawn::Document.new(page_size: "A4",
        page_layout: :portrait,
        margin: 2.cm)

      slip = ::Export::Pdf::Invoice::PaymentSlipQr.new(pdf, invoice, {})
      expect(::Export::Pdf::Invoice::PaymentSlipQr).to receive(:new).and_return(slip)
      expect(slip).to receive(:separators_without_configuration)
      subject
    end

    it "renders the whole text" do
      invoice_text = [
        [459, 529, "Datum: 15.06.2022"],
        [57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"],
        [57, 529, "Invoice"],
        [57, 494, "Rechnungsnummer: 636980692-2 vom 15.06.2022"],
        [414, 494, "Anzahl"],
        [472, 494, "Preis"],
        [515, 494, "Betrag"],
        [404, 480, "Zwischenbetrag"],
        [506, 480, "0.00 CHF"],
        [404, 462, "Gesamtbetrag"],
        [505, 462, "0.00 CHF"],
        [57, 463, "Fällig bis:      01.08.2022"],
        [14, 276, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 241, "CH93 0076 2011 6238 5295 7"],
        [14, 232, "Puzzle"],
        [14, 223, "Belpstrasse 37"],
        [14, 214, "3007 Bern"],
        [14, 194, "Referenznummer"],
        [14, 185, "00 00376 80338 90000 00000 00021"],
        [14, 166, "Zahlbar durch"],
        [14, 156, "Max Muster"],
        [14, 147, "Belpstrasse 37"],
        [14, 137, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 276, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 264, "CH93 0076 2011 6238 5295 7"],
        [346, 253, "Puzzle"],
        [346, 241, "Belpstrasse 37"],
        [346, 230, "3007 Bern"],
        [346, 208, "Referenznummer"],
        [346, 196, "00 00376 80338 90000 00000 00021"],
        [346, 175, "Zahlbar durch"],
        [346, 163, "Max Muster"],
        [346, 151, "Belpstrasse 37"],
        [346, 140, "3007 Bern"]
      ]
      invoice_text.each_with_index do |text, i|
        expect(text_with_position[i]).to eq(text)
      end
    end

    it "renders everything else regardless" do
      invoice_text = [
        [459, 529, "Datum: 15.06.2022"],
        [57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"],
        [57, 529, "Invoice"],
        [57, 494, "Rechnungsnummer: 636980692-2 vom 15.06.2022"],
        [414, 494, "Anzahl"],
        [472, 494, "Preis"],
        [515, 494, "Betrag"],
        [404, 480, "Zwischenbetrag"],
        [506, 480, "0.00 CHF"],
        [404, 462, "Gesamtbetrag"],
        [505, 462, "0.00 CHF"],
        [57, 463, "Fällig bis:      01.08.2022"],
        [14, 276, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 241, "CH93 0076 2011 6238 5295 7"],
        [14, 232, "Puzzle"],
        [14, 223, "Belpstrasse 37"],
        [14, 214, "3007 Bern"],
        [14, 194, "Referenznummer"],
        [14, 185, "00 00376 80338 90000 00000 00021"],
        [14, 166, "Zahlbar durch"],
        [14, 156, "Max Muster"],
        [14, 147, "Belpstrasse 37"],
        [14, 137, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 276, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 264, "CH93 0076 2011 6238 5295 7"],
        [346, 253, "Puzzle"],
        [346, 241, "Belpstrasse 37"],
        [346, 230, "3007 Bern"],
        [346, 208, "Referenznummer"],
        [346, 196, "00 00376 80338 90000 00000 00021"],
        [346, 175, "Zahlbar durch"],
        [346, 163, "Max Muster"],
        [346, 151, "Belpstrasse 37"],
        [346, 140, "3007 Bern"]
      ]
      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
    end

    it "does not render issued_at behind_sequence_number when issued_at is not set" do
      invoice.update!(issued_at: nil)
      invoice_text = [
        [57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"],
        [57, 529, "Invoice"],
        [57, 494, "Rechnungsnummer: 636980692-2"],
        [414, 494, "Anzahl"],
        [472, 494, "Preis"],
        [515, 494, "Betrag"],
        [404, 480, "Zwischenbetrag"],
        [506, 480, "0.00 CHF"],
        [404, 462, "Gesamtbetrag"],
        [505, 462, "0.00 CHF"],
        [57, 463, "Fällig bis:      01.08.2022"],
        [14, 276, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 241, "CH93 0076 2011 6238 5295 7"],
        [14, 232, "Puzzle"],
        [14, 223, "Belpstrasse 37"],
        [14, 214, "3007 Bern"],
        [14, 194, "Referenznummer"],
        [14, 185, "00 00376 80338 90000 00000 00021"],
        [14, 166, "Zahlbar durch"],
        [14, 156, "Max Muster"],
        [14, 147, "Belpstrasse 37"],
        [14, 137, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 276, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 264, "CH93 0076 2011 6238 5295 7"],
        [346, 253, "Puzzle"],
        [346, 241, "Belpstrasse 37"],
        [346, 230, "3007 Bern"],
        [346, 208, "Referenznummer"],
        [346, 196, "00 00376 80338 90000 00000 00021"],
        [346, 175, "Zahlbar durch"],
        [346, 163, "Max Muster"],
        [346, 151, "Belpstrasse 37"],
        [346, 140, "3007 Bern"]
      ]
      invoice_text.each_with_index do |text, i|
        expect(text_with_position[i]).to eq(text)
      end
    end

    it "renders created at of latest reminder when reminder exists as invoice date" do
      invoice.invoice_items.build(name: "pens", unit_cost: 10, vat_rate: 10, count: 2, invoice: invoice)
      invoice.update!(issued_at: Date.new(2025, 1, 1), due_at: 5.days.from_now, state: "sent")
      PaymentReminder.create!(level: 1, due_at: 10.days.from_now, invoice: invoice, title: "Reminder 1", created_at: 10.days.from_now)
      invoice_text = [
        [459, 529, "Datum: #{I18n.l(10.days.from_now.to_date)}"],
        [57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"],
        [57, 529, "Reminder 1 - Invoice"],
        [57, 486, "Rechnungsnummer: 636980692-2 vom 01.01.2025"],
        [364, 486, "Anzahl"],
        [422, 486, "Preis"],
        [465, 486, "Betrag"],
        [515, 486, "MwSt."],
        [57, 471, "pens"],
        [384, 472, "2"],
        [419, 472, "10.00"],
        [469, 472, "20.00"],
        [514, 472, "10.0 %"],
        [400, 458, "Zwischenbetrag"],
        [502, 458, "20.00 CHF"],
        [400, 443, "MwSt."],
        [506, 443, "2.00 CHF"],
        [400, 425, "Gesamtbetrag"],
        [501, 425, "22.00 CHF"],
        [57, 426, "Fällig bis:      #{I18n.l(10.days.from_now.to_date)}"],
        [14, 276, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 241, "CH93 0076 2011 6238 5295 7"],
        [14, 232, "Puzzle"],
        [14, 223, "Belpstrasse 37"],
        [14, 214, "3007 Bern"],
        [14, 194, "Referenznummer"],
        [14, 185, "00 00376 80338 90000 00000 00021"],
        [14, 166, "Zahlbar durch"],
        [14, 156, "Max Muster"],
        [14, 147, "Belpstrasse 37"],
        [14, 137, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [71, 77, "22.00"],
        [105, 39, "Annahmestelle"],
        [190, 276, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [247, 76, "22.00"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 264, "CH93 0076 2011 6238 5295 7"],
        [346, 253, "Puzzle"],
        [346, 241, "Belpstrasse 37"],
        [346, 230, "3007 Bern"],
        [346, 208, "Referenznummer"],
        [346, 196, "00 00376 80338 90000 00000 00021"],
        [346, 175, "Zahlbar durch"],
        [346, 163, "Max Muster"],
        [346, 151, "Belpstrasse 37"],
        [346, 140, "3007 Bern"]
      ]
      invoice_text.each_with_index do |text, i|
        expect(text_with_position[i]).to eq(text)
      end
    end

    context "without reminders" do
      let(:pdf) { described_class.render(invoice, payment_slip: true, articles: true, reminders: false) }

      it "does not render reminder and reminder date" do
        invoice.invoice_items.build(name: "pens", unit_cost: 10, vat_rate: 10, count: 2, invoice: invoice)
        invoice.update!(issued_at: Date.new(2025, 1, 1), due_at: 5.days.from_now, state: "sent")
        PaymentReminder.create!(level: 1, due_at: 10.days.from_now, invoice: invoice, title: "Reminder 1", created_at: 10.days.from_now)
        invoice_text = [
          [459, 529, "Datum: 01.01.2025"],
          [57, 687, "Max Muster"],
          [57, 674, "Belpstrasse 37"],
          [57, 661, "3007 Bern"],
          [57, 529, "Invoice"],
          [57, 494, "Rechnungsnummer: 636980692-2 vom 01.01.2025"],
          [364, 494, "Anzahl"],
          [422, 494, "Preis"],
          [465, 494, "Betrag"],
          [515, 494, "MwSt."],
          [57, 479, "pens"],
          [384, 480, "2"],
          [419, 480, "10.00"],
          [469, 480, "20.00"],
          [514, 480, "10.0 %"],
          [400, 466, "Zwischenbetrag"],
          [502, 466, "20.00 CHF"],
          [400, 451, "MwSt."],
          [506, 451, "2.00 CHF"],
          [400, 433, "Gesamtbetrag"],
          [501, 433, "22.00 CHF"],
          [57, 434, "Fällig bis:      #{I18n.l(10.days.from_now.to_date)}"],
          [14, 276, "Empfangsschein"],
          [14, 251, "Konto / Zahlbar an"],
          [14, 241, "CH93 0076 2011 6238 5295 7"],
          [14, 232, "Puzzle"],
          [14, 223, "Belpstrasse 37"],
          [14, 214, "3007 Bern"],
          [14, 194, "Referenznummer"],
          [14, 185, "00 00376 80338 90000 00000 00021"],
          [14, 166, "Zahlbar durch"],
          [14, 156, "Max Muster"],
          [14, 147, "Belpstrasse 37"],
          [14, 137, "3007 Bern"],
          [14, 89, "Währung"],
          [71, 89, "Betrag"],
          [14, 77, "CHF"],
          [71, 77, "22.00"],
          [105, 39, "Annahmestelle"],
          [190, 276, "Zahlteil"],
          [190, 88, "Währung"],
          [247, 88, "Betrag"],
          [190, 76, "CHF"],
          [247, 76, "22.00"],
          [346, 276, "Konto / Zahlbar an"],
          [346, 264, "CH93 0076 2011 6238 5295 7"],
          [346, 253, "Puzzle"],
          [346, 241, "Belpstrasse 37"],
          [346, 230, "3007 Bern"],
          [346, 208, "Referenznummer"],
          [346, 196, "00 00376 80338 90000 00000 00021"],
          [346, 175, "Zahlbar durch"],
          [346, 163, "Max Muster"],
          [346, 151, "Belpstrasse 37"],
          [346, 140, "3007 Bern"]
        ]
        invoice_text.each_with_index do |text, i|
          expect(text_with_position[i]).to eq(text)
        end
      end

      it "renders membership card when reminders false" do
        invoice.update!(membership_card: true, membership_expires_on: Date.new(2022, 1, 1), due_at: 10.days.ago, state: "reminded")
        Fabricate(:payment_reminder, invoice: invoice, due_at: 3.day.ago, created_at: 5.days.ago)

        expect(text_with_position).to include([346, 721, "Mitgliederausweis"])
      end
    end

    it "renders total when hide_total=false" do
      InvoiceItem.create!(invoice: invoice, name: "dings", count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: false)
      invoice.reload.recalculate!
      expect(rows_with_text("Gesamtbetrag")).to include([400, 433, "Gesamtbetrag"])
      expect(rows_at_position(433)).to include([501, 433, "11.00 CHF"])

      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it "renders subtotal and donation row when hide_total=true" do
      InvoiceItem.create!(invoice: invoice, name: "dings", count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: true)
      invoice.reload.recalculate!

      expect(rows_with_text("Subtotal")).to include([400, 451, "Subtotal"])
      expect(rows_at_position(451)).to include([501, 451, "11.00 CHF"])

      expect(rows_with_text("Spende")).to include([400, 437, "Spende"])
      expect(rows_with_text("Gesamtbetrag")).to include([400, 419, "Gesamtbetrag"])
    end
  end

  context "with separators false" do
    before { invoice_config.update!(separators: false) }

    it "does not render separators" do
      pdf = Prawn::Document.new(page_size: "A4",
        page_layout: :portrait,
        margin: 2.cm)

      slip = ::Export::Pdf::Invoice::PaymentSlipQr.new(pdf, invoice, {})
      expect(::Export::Pdf::Invoice::PaymentSlipQr).to receive(:new).and_return(slip)
      expect(slip).to_not receive(:separators_without_configuration)
      subject
    end

    it "renders everything else regardless" do
      invoice_text = [
        [459, 529, "Datum: 15.06.2022"],
        [57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"],
        [57, 529, "Invoice"],
        [57, 494, "Rechnungsnummer: 636980692-2 vom 15.06.2022"],
        [414, 494, "Anzahl"],
        [472, 494, "Preis"],
        [515, 494, "Betrag"],
        [404, 480, "Zwischenbetrag"],
        [506, 480, "0.00 CHF"],
        [404, 462, "Gesamtbetrag"],
        [505, 462, "0.00 CHF"],
        [57, 463, "Fällig bis:      01.08.2022"],
        [14, 276, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 241, "CH93 0076 2011 6238 5295 7"],
        [14, 232, "Puzzle"],
        [14, 223, "Belpstrasse 37"],
        [14, 214, "3007 Bern"],
        [14, 194, "Referenznummer"],
        [14, 185, "00 00376 80338 90000 00000 00021"],
        [14, 166, "Zahlbar durch"],
        [14, 156, "Max Muster"],
        [14, 147, "Belpstrasse 37"],
        [14, 137, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 276, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 264, "CH93 0076 2011 6238 5295 7"],
        [346, 253, "Puzzle"],
        [346, 241, "Belpstrasse 37"],
        [346, 230, "3007 Bern"],
        [346, 208, "Referenznummer"],
        [346, 196, "00 00376 80338 90000 00000 00021"],
        [346, 175, "Zahlbar durch"],
        [346, 163, "Max Muster"],
        [346, 151, "Belpstrasse 37"],
        [346, 140, "3007 Bern"]
      ]
      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
    end

    it "renders total when hide_total=false" do
      InvoiceItem.create!(invoice: invoice, name: "dings", count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: false)
      invoice.reload.recalculate!
      expect(rows_with_text("Gesamtbetrag")).to include([400, 433, "Gesamtbetrag"])
      expect(rows_at_position(433)).to include([501, 433, "11.00 CHF"])

      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it "renders subtotal and donation row when hide_total=true" do
      InvoiceItem.create!(invoice: invoice, name: "dings", count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: true)
      invoice.reload.recalculate!
      expect(rows_with_text("Subtotal")).to include([400, 451, "Subtotal"])
      expect(rows_at_position(451)).to include([501, 451, "11.00 CHF"])

      expect(rows_with_text("Spende")).to eq [[400, 437, "Spende"]]
      expect(rows_with_text("Gesamtbetrag")).to eq [[400, 419, "Gesamtbetrag"]]
    end
  end

  context "rendered right" do
    before do
      invoice.group.letter_address_position = :right
      invoice.group.save!
    end

    it "renders membership_card when true" do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse("2022-10-01"))
      membership_card = [
        [57, 721, "Mitgliederausweis"],
        [57, 710, "42421"],
        [57, 699, "Bob Foo"],
        [222, 721, "Gültig bis"],
        [227, 710, "10.2022"]
      ]
      expect(text_with_position).to include(*membership_card)
    end

    it "renders receiver address" do
      expect(text_with_position).to include([347, 687, "Max Muster"],
        [347, 674, "Belpstrasse 37"],
        [347, 661, "3007 Bern"])
    end
  end

  context "rendered at custom position" do
    before do
      invoice.group.letter_left_address_position = 3 # 3.cm = 85
      invoice.group.letter_top_address_position = 5
      invoice.group.save!
    end

    it "renders membership_card when true" do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse("2022-10-01"))
      membership_card = [
        [346, 721, "Mitgliederausweis"],
        [346, 710, "42421"],
        [346, 699, "Bob Foo"],
        [511, 721, "Gültig bis"],
        [517, 710, "10.2022"]
      ]

      expect(text_with_position).to include(*membership_card)
    end

    it "renders receiver address" do
      expect(text_with_position).to include([85, 690, "Max Muster"],
        [85, 677, "Belpstrasse 37"],
        [85, 664, "3007 Bern"])
    end
  end

  it "renders invoice information to the right" do
    expect(text_with_position.find { _3 == "Datum: 15.06.2022" }).to start_with(459, 529)
  end

  it "renders invoice number as column label" do
    expect(text_with_position.find { _3.starts_with?("Rechnungsnummer") }).to end_with(["Rechnungsnummer: 636980692-2 vom 15.06.2022"])
  end

  it "renders invoice due at below articles table" do
    due_at = text_with_position.find { _3.starts_with?("Fällig bis") }

    expect(due_at).to start_with(57, 463)
    expect(invoice.due_at).to eql Date.parse("2022-08-01")
    expect(due_at).to end_with "Fällig bis:      01.08.2022"
  end

  context do
    let(:invoice) do
      invoices(:invoice).tap do |i|
        i.update!(
          payment_slip: :qr,
          payee: "Puzzle\nBelpstrasse 37\n3007 Bern",
          iban: "CH93 0076 2011 6238 5295 7",
          issued_at: Date.parse("2022-06-15"),
          due_at: Date.parse("2022-08-01")
        )
        InvoiceItem.create(invoice: i, name: "dings", count: 1, unit_cost: 10, vat_rate: 10)
        i.reload.recalculate!
      end
    end

    context "with hide_total=false" do
      before { invoice.update!(hide_total: false) }

      it "renders total" do
        expect(rows_with_text("Gesamtbetrag")).to include([400, 433, "Gesamtbetrag"])
        expect(rows_at_position(433)).to include([501, 433, "11.00 CHF"])

        full_text = subject.show_text.join("\n")
        expect(full_text).not_to include("Subtotal")
        expect(full_text).not_to include("Spende")
      end

      it "renders partial payments" do
        invoice.payments.build(amount: 5, received_at: Time.zone.yesterday)
        invoice.payments.build(amount: 3, received_at: Time.zone.yesterday)
        invoice.save!
        invoice.reload.recalculate!

        labels = text_with_position.select { |x, y, text| (390..410).cover?(x) }
        expect(labels).to include(
          [400, 466, "Zwischenbetrag"],
          [400, 451, "MwSt."],
          [400, 436, "Gesamtbetrag"],
          [400, 423, "Eingegangene Zahlung"],
          [400, 408, "Eingegangene Zahlung"],
          [400, 390, "Offener Betrag"]
        )

        numbers = text_with_position.select { |x, y, text| (490..510).cover?(x) }
        expect(numbers).to include(
          [502, 466, "10.00 CHF"],
          [506, 451, "1.00 CHF"],
          [501, 436, "11.00 CHF"],
          [506, 423, "5.00 CHF"],
          [506, 408, "3.00 CHF"],
          [505, 390, "3.00 CHF"]
        )
      end
    end

    context "with hide_total=true" do
      before { invoice.update!(hide_total: true) }

      it "renders subtotal and donation row" do
        expect(rows_with_text("Subtotal")).to include([400, 451, "Subtotal"])
        expect(rows_at_position(451)).to include([501, 451, "11.00 CHF"])

        expect(rows_with_text("Spende")).to include([400, 437, "Spende"])
        expect(rows_with_text("Gesamtbetrag")).to include([400, 419, "Gesamtbetrag"])
      end

      it "renders partial payments" do
        invoice.payments.build(amount: 5, received_at: Time.zone.yesterday)
        invoice.payments.build(amount: 3, received_at: Time.zone.yesterday)
        invoice.save!
        invoice.reload.recalculate!

        labels = text_with_position.select { |x, y, text| (390..410).cover?(x) }
        expect(labels).to include(
          [401, 466, "Zwischenbetrag"],
          [401, 451, "MwSt."],
          [401, 437, "Eingegangene Zahlung"],
          [401, 422, "Eingegangene Zahlung"],
          [401, 407, "Offener Betrag"]
        )

        numbers = text_with_position.select { |x, y, text| (490..510).cover?(x) }
        expect(numbers).to include(
          [502, 466, "10.00 CHF"],
          [506, 451, "1.00 CHF"],
          [506, 437, "5.00 CHF"],
          [506, 422, "3.00 CHF"],
          [505, 407, "3.00 CHF"]
        )
      end
    end
  end
end
