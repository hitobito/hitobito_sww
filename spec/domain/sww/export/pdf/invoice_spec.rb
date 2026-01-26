# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
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
        payee_name: "Puzzle",
        payee_street: "Belpstrasse",
        payee_housenumber: "37",
        payee_zip_code: "3007",
        payee_town: "Bern",
        iban: "CH93 0076 2011 6238 5295 7",
        issued_at: Date.parse("2022-06-15"),
        due_at: Date.parse("2022-08-01")
      )
    end
  end

  let(:invoice_config) do
    invoice.invoice_config
  end

  let(:payment_slip) { true }

  let(:pdf) {
    described_class.render(invoice, payment_slip: payment_slip, articles: true, reminders: true)
  }

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

      [:disabled, :left, :right, :bottom_left].each do |position|
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
        invoice.invoice_config.update(logo_position: logo_position)
      end

      context "with logo_position=disabled" do
        let(:logo_position) { :disabled }

        it "does not render the logo" do
          expect(image_positions).to have(1).item # only qr code
        end
      end

      context "with logo_position=left" do
        let(:logo_position) { :left }

        it "renders the logo on the left" do
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
      end

      context "with logo_position=right" do
        let(:logo_position) { :right }

        it "renders the logo on the right" do
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
      end

      context "with logo_position=bottom_left" do
        # For these tests we have to mock the repeat call,
        # since PDF::Inspector::Text.analzye can not read repeated texts
        # see https://github.com/prawnpdf/pdf-inspector/issues/25

        let(:logo_position) { :bottom_left }

        it "renders the logo above the payment slip" do
          expect(image_positions).to have(2).items
          expect(image_positions.first).to match(
            displayed_height: 18_912.75561,
            displayed_width: 108_763.38,
            height: 417,
            width: 1000,
            x: 56.69291,
            y: 314.64567
          )
        end

        context "with logo_on_every_page" do
          before do
            invoice.invoice_config.update! logo_on_every_page: true
          end

          it "renders the logo on first page" do
            20.times do |i|
              invoice.invoice_items.build(name: "pen #{i}", unit_cost: 10, vat_rate: 10, count: 2)
            end

            expect_any_instance_of(Sww::Export::Pdf::Invoice::FooterLogo)
              .to receive(:repeat_footer_logo)
              .with([1]) do |&block|
                block.call
              end

            pdf
          end
        end

        context "without payment slip" do
          let(:payment_slip) { false }

          it "renders the logo at bottom left" do
            expect_any_instance_of(Sww::Export::Pdf::Invoice::FooterLogo)
              .to receive(:repeat_footer_logo)
              .with([1]) do |&block|
                block.call
              end

            expect(image_positions).to have(1).items
            expect(image_positions.first).to match(
              displayed_height: 18_912.75561,
              displayed_width: 108_763.38,
              height: 417,
              width: 1000,
              x: 36.69291,
              y: 21.33858
            )
          end
        end

        context "without payment slip but logo_on_every_page" do
          let(:payment_slip) { false }

          before do
            invoice.invoice_config.update! logo_on_every_page: true
          end

          it "renders the logo on every page" do
            28.times do |i|
              invoice.invoice_items.build(name: "pen #{i}", unit_cost: 10, vat_rate: 10, count: 2)
            end

            expect_any_instance_of(Sww::Export::Pdf::Invoice::FooterLogo)
              .to receive(:repeat_footer_logo)
              .with([1, 2]) do |&block|
                block.call
              end

            expect(image_positions(2)).to have(1).items
          end
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

      it "with logo_position=bottom_left it renders logo above the payment slip" do
        invoice.invoice_config.update(logo_position: :bottom_left)
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
      invoice.update!(membership_card: true, membership_expires_on: Date.parse("2022-10-01"),
        address: "Sender address")
      membership_card = [
        [346, 721, "Mitgliederausweis"],
        [346, 710, "42421"],
        [346, 699, "Bob Foo"],
        [511, 721, "Gültig bis"],
        [517, 710, "10.2022"]
      ]

      expect(text_with_position).to include(*membership_card)
      expect(text_with_position.map(&:last)).to include("Mitgliederausweis")
      expect(text_with_position.map(&:last)).not_to include("Sender address")
    end

    it "does not render membership card when invoice has reminder" do
      invoice.update!(membership_card: true, membership_expires_on: Date.new(2022, 1, 1),
        due_at: 10.days.ago, state: "reminded")
      Fabricate(:payment_reminder, invoice: invoice, due_at: 3.days.ago, created_at: 5.days.ago)

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
      pdf = Export::Pdf::Document.new(page_size: "A4",
        page_layout: :portrait,
        margin: 2.cm).pdf

      slip = ::Export::Pdf::Invoice::PaymentSlipQr.new(pdf, invoice, {})
      expect(::Export::Pdf::Invoice::PaymentSlipQr).to receive(:new).and_return(slip)
      expect(slip).to receive(:separators_without_configuration)
      subject
    end

    it "renders the whole text" do
      invoice_text = [
        [459, 529, "Datum: 15.06.2022"],
        [430, 545, "Mitgliedernummer: 42421"],
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
        [14, 275, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 242, "CH93 0076 2011 6238 5295 7"],
        [14, 233, "Puzzle"],
        [14, 225, "Belpstrasse 37"],
        [14, 216, "3007 Bern"],
        [14, 197, "Referenznummer"],
        [14, 189, "00 00376 80338 90000 00000 00021"],
        [14, 170, "Zahlbar durch"],
        [14, 161, "Max Muster"],
        [14, 152, "Belpstrasse 37"],
        [14, 144, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 275, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 265, "CH93 0076 2011 6238 5295 7"],
        [346, 254, "Puzzle"],
        [346, 244, "Belpstrasse 37"],
        [346, 233, "3007 Bern"],
        [346, 212, "Referenznummer"],
        [346, 201, "00 00376 80338 90000 00000 00021"],
        [346, 180, "Zahlbar durch"],
        [346, 169, "Max Muster"],
        [346, 158, "Belpstrasse 37"],
        [346, 147, "3007 Bern"]
      ]
      invoice_text.each_with_index do |text, i|
        expect(text_with_position[i]).to eq(text)
      end
    end

    it "renders everything else regardless" do
      invoice_text = [
        [459, 529, "Datum: 15.06.2022"],
        [430, 545, "Mitgliedernummer: 42421"],
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
        [14, 275, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 242, "CH93 0076 2011 6238 5295 7"],
        [14, 233, "Puzzle"],
        [14, 225, "Belpstrasse 37"],
        [14, 216, "3007 Bern"],
        [14, 197, "Referenznummer"],
        [14, 189, "00 00376 80338 90000 00000 00021"],
        [14, 170, "Zahlbar durch"],
        [14, 161, "Max Muster"],
        [14, 152, "Belpstrasse 37"],
        [14, 144, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 275, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 265, "CH93 0076 2011 6238 5295 7"],
        [346, 254, "Puzzle"],
        [346, 244, "Belpstrasse 37"],
        [346, 233, "3007 Bern"],
        [346, 212, "Referenznummer"],
        [346, 201, "00 00376 80338 90000 00000 00021"],
        [346, 180, "Zahlbar durch"],
        [346, 169, "Max Muster"],
        [346, 158, "Belpstrasse 37"],
        [346, 147, "3007 Bern"]
      ]
      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
    end

    it "does not render issued_at behind_sequence_number when issued_at is not set" do
      invoice.update!(issued_at: nil)
      invoice_text = [
        [430, 529, "Mitgliedernummer: 42421"],
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
        [14, 275, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 242, "CH93 0076 2011 6238 5295 7"],
        [14, 233, "Puzzle"],
        [14, 225, "Belpstrasse 37"],
        [14, 216, "3007 Bern"],
        [14, 197, "Referenznummer"],
        [14, 189, "00 00376 80338 90000 00000 00021"],
        [14, 170, "Zahlbar durch"],
        [14, 161, "Max Muster"],
        [14, 152, "Belpstrasse 37"],
        [14, 144, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 275, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 265, "CH93 0076 2011 6238 5295 7"],
        [346, 254, "Puzzle"],
        [346, 244, "Belpstrasse 37"],
        [346, 233, "3007 Bern"],
        [346, 212, "Referenznummer"],
        [346, 201, "00 00376 80338 90000 00000 00021"],
        [346, 180, "Zahlbar durch"],
        [346, 169, "Max Muster"],
        [346, 158, "Belpstrasse 37"],
        [346, 147, "3007 Bern"]
      ]
      invoice_text.each_with_index do |text, i|
        expect(text_with_position[i]).to eq(text)
      end
    end

    it "renders created at of latest reminder when reminder exists as invoice date" do
      invoice.invoice_items.build(name: "pens", unit_cost: 10, vat_rate: 10, count: 2,
        invoice: invoice)
      invoice.update!(issued_at: Date.new(2025, 1, 1), due_at: 5.days.from_now, state: "sent")
      PaymentReminder.create!(level: 1, due_at: 10.days.from_now, invoice: invoice,
        title: "Reminder 1", created_at: 10.days.from_now)
      invoice_text = [
        [459, 529, "Datum: #{I18n.l(10.days.from_now.to_date)}"],
        [430, 545, "Mitgliedernummer: 42421"],
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
        [14, 275, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 242, "CH93 0076 2011 6238 5295 7"],
        [14, 233, "Puzzle"],
        [14, 225, "Belpstrasse 37"],
        [14, 216, "3007 Bern"],
        [14, 197, "Referenznummer"],
        [14, 189, "00 00376 80338 90000 00000 00021"],
        [14, 170, "Zahlbar durch"],
        [14, 161, "Max Muster"],
        [14, 152, "Belpstrasse 37"],
        [14, 144, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [71, 77, "22.00"],
        [105, 39, "Annahmestelle"],
        [190, 275, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [247, 76, "22.00"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 265, "CH93 0076 2011 6238 5295 7"],
        [346, 254, "Puzzle"],
        [346, 244, "Belpstrasse 37"],
        [346, 233, "3007 Bern"],
        [346, 212, "Referenznummer"],
        [346, 201, "00 00376 80338 90000 00000 00021"],
        [346, 180, "Zahlbar durch"],
        [346, 169, "Max Muster"],
        [346, 158, "Belpstrasse 37"],
        [346, 147, "3007 Bern"]
      ]
      invoice_text.each_with_index do |text, i|
        expect(text_with_position[i]).to eq(text)
      end
    end

    context "without reminders" do
      let(:pdf) {
        described_class.render(invoice, payment_slip: true, articles: true, reminders: false)
      }

      it "does not render reminder and reminder date" do
        invoice.invoice_items.build(name: "pens", unit_cost: 10, vat_rate: 10, count: 2,
          invoice: invoice)
        invoice.update!(issued_at: Date.new(2025, 1, 1), due_at: 5.days.from_now, state: "sent")
        PaymentReminder.create!(level: 1, due_at: 10.days.from_now, invoice: invoice,
          title: "Reminder 1", created_at: 10.days.from_now)
        invoice_text = [
          [459, 529, "Datum: 01.01.2025"],
          [430, 545, "Mitgliedernummer: 42421"],
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
          [14, 275, "Empfangsschein"],
          [14, 251, "Konto / Zahlbar an"],
          [14, 242, "CH93 0076 2011 6238 5295 7"],
          [14, 233, "Puzzle"],
          [14, 225, "Belpstrasse 37"],
          [14, 216, "3007 Bern"],
          [14, 197, "Referenznummer"],
          [14, 189, "00 00376 80338 90000 00000 00021"],
          [14, 170, "Zahlbar durch"],
          [14, 161, "Max Muster"],
          [14, 152, "Belpstrasse 37"],
          [14, 144, "3007 Bern"],
          [14, 89, "Währung"],
          [71, 89, "Betrag"],
          [14, 77, "CHF"],
          [71, 77, "22.00"],
          [105, 39, "Annahmestelle"],
          [190, 275, "Zahlteil"],
          [190, 88, "Währung"],
          [247, 88, "Betrag"],
          [190, 76, "CHF"],
          [247, 76, "22.00"],
          [346, 276, "Konto / Zahlbar an"],
          [346, 265, "CH93 0076 2011 6238 5295 7"],
          [346, 254, "Puzzle"],
          [346, 244, "Belpstrasse 37"],
          [346, 233, "3007 Bern"],
          [346, 212, "Referenznummer"],
          [346, 201, "00 00376 80338 90000 00000 00021"],
          [346, 180, "Zahlbar durch"],
          [346, 169, "Max Muster"],
          [346, 158, "Belpstrasse 37"],
          [346, 147, "3007 Bern"]
        ]
        invoice_text.each_with_index do |text, i|
          expect(text_with_position[i]).to eq(text)
        end
      end

      it "renders membership card when reminders false" do
        invoice.update!(membership_card: true, membership_expires_on: Date.new(2022, 1, 1),
          due_at: 10.days.ago, state: "reminded")
        Fabricate(:payment_reminder, invoice: invoice, due_at: 3.days.ago, created_at: 5.days.ago)

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
      pdf = Export::Pdf::Document.new(page_size: "A4",
        page_layout: :portrait,
        margin: 2.cm).pdf

      slip = ::Export::Pdf::Invoice::PaymentSlipQr.new(pdf, invoice, {})
      expect(::Export::Pdf::Invoice::PaymentSlipQr).to receive(:new).and_return(slip)
      expect(slip).to_not receive(:separators_without_configuration)
      subject
    end

    it "renders everything else regardless" do
      invoice_text = [
        [459, 529, "Datum: 15.06.2022"],
        [430, 545, "Mitgliedernummer: 42421"],
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
        [14, 275, "Empfangsschein"],
        [14, 251, "Konto / Zahlbar an"],
        [14, 242, "CH93 0076 2011 6238 5295 7"],
        [14, 233, "Puzzle"],
        [14, 225, "Belpstrasse 37"],
        [14, 216, "3007 Bern"],
        [14, 197, "Referenznummer"],
        [14, 189, "00 00376 80338 90000 00000 00021"],
        [14, 170, "Zahlbar durch"],
        [14, 161, "Max Muster"],
        [14, 152, "Belpstrasse 37"],
        [14, 144, "3007 Bern"],
        [14, 89, "Währung"],
        [71, 89, "Betrag"],
        [14, 77, "CHF"],
        [105, 39, "Annahmestelle"],
        [190, 275, "Zahlteil"],
        [190, 88, "Währung"],
        [247, 88, "Betrag"],
        [190, 76, "CHF"],
        [346, 276, "Konto / Zahlbar an"],
        [346, 265, "CH93 0076 2011 6238 5295 7"],
        [346, 254, "Puzzle"],
        [346, 244, "Belpstrasse 37"],
        [346, 233, "3007 Bern"],
        [346, 212, "Referenznummer"],
        [346, 201, "00 00376 80338 90000 00000 00021"],
        [346, 180, "Zahlbar durch"],
        [346, 169, "Max Muster"],
        [346, 158, "Belpstrasse 37"],
        [346, 147, "3007 Bern"]
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
      expect(text_with_position).to include([57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"])
    end
  end

  context "invoice information" do
    it "renders date to the right" do
      expect(text_with_position.find { _3 == "Datum: 15.06.2022" }).to start_with(459, 529)
    end

    it "renders member_number below date" do
      expect(text_with_position.find {
        _3.starts_with?("Mitgliedernummer")
      }).to start_with(430, 545)
    end

    it "renders member_number at vertical position of date when date is missing" do
      invoice.update!(issued_at: nil)
      expect(text_with_position.find {
        _3.starts_with?("Mitgliedernummer")
      }).to start_with(430, 529)
    end

    it "renders only the date when invoice.recipient has no member_number" do
      allow(invoice.recipient).to receive(:member_number).and_raise(NoMethodError)
      allow(invoice.recipient).to receive(:respond_to?).with(:member_number).and_return(false)

      expect(text_with_position.find { _3 == "Datum: 15.06.2022" }).to start_with(459, 529)
      expect(text_with_position.find { _3.starts_with?("Mitgliedernummer") }).to be_nil
    end
  end

  it "renders invoice number as column label" do
    expect(text_with_position.find {
      _3.starts_with?("Rechnungsnummer")
    }).to end_with(["Rechnungsnummer: 636980692-2 vom 15.06.2022"])
  end

  it "renders invoice due at below articles table" do
    due_at = text_with_position.find { _3.starts_with?("Fällig bis") }

    expect(due_at).to start_with(57, 463)
    expect(invoice.due_at).to eql Date.parse("2022-08-01")
    expect(due_at).to end_with "Fällig bis:      01.08.2022"
  end

  context "with invoice item" do
    let(:invoice) do
      invoices(:invoice).tap do |i|
        i.update!(
          payment_slip: :qr,
          payee_name: "Puzzle",
          payee_street: "Belpstrasse",
          payee_housenumber: "37",
          payee_zip_code: "3007",
          payee_town: "Bern",
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

    context "with use_header=true" do
      before do
        # We have to mock the repeat_all call, since PDF::Inspector::Text.analzye can not read
        # repeated texts, see https://github.com/prawnpdf/pdf-inspector/issues/25
        expect_any_instance_of(Sww::Export::Pdf::Invoice::PageHeader)
          .to receive(:repeat_all) { |&block| block.call }
      end

      it "renders header on every page" do
        invoice_config.update!(use_header: true,
          header: "<p>This is a <strong>header</strong><br/>With multiple lines</p>")

        header = [
          [57, 803, "This is a "],
          [90, 803, "header"],
          [57, 791, "With multiple lines"]
        ]

        expect(text_with_position).to include(*header)
      end

      it "renders all lines of very heigh header" do
        invoice_config.update!(use_header: true,
          header: "<p>This is a <strong>header</strong><br/>With multiple lines</p><br/>" \
            "Line<br/>Line</br>Line<br/>Line<br/>Line")

        expect(text_with_position.map(&:third).count("Line")).to eq 5
      end
    end
  end
end
