# frozen_string_literal: true

#  Copyright (c) 2012-2024, Schweizer Wanderwege. This file is part of
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

  def rows_with_text(text)
    text_with_position.select { |x, y, content| content == text }
  end


  context 'rendered left' do
    before do
      invoice.group.letter_address_position = :left
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      membership_card = [
        [346, 721, "Mitgliederausweis"],
        [346, 710, "42421"],
        [346, 699, "Bob Foo"],
        [511, 721, "Gültig bis"],
        [517, 710, "10.2022"]
      ]

      expect(text_with_position).to include(*membership_card)
    end

    it 'renders receiver address' do
      expect(text_with_position).to include(
        [57, 687, "Max Muster"],
        [57, 674, "Belpstrasse 37"],
        [57, 661, "3007 Bern"]
      )
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

    it 'renders the whole text' do
      invoice_text = [
        "Rechnungsdatum: 15.06.2022",
        "Max Muster",
        "Belpstrasse 37",
        "3007 Bern",
        "Invoice",
        "Rechnungsnummer: 636980692-2",
        "Anzahl",
        "Preis",
        "Betrag",
        "MwSt.",
        "Zwischenbetrag",
        "0.00 CHF",
        "Gesamtbetrag",
        "0.00 CHF",
        "Fällig bis:      01.08.2022",
        "Empfangsschein",
        "Konto / Zahlbar an",
        "CH93 0076 2011 6238 5295 7",
        "Puzzle",
        "Belpstrasse 37",
        "3007 Bern",
        "Zahlbar durch",
        "Max Muster",
        "Belpstrasse 37",
        "3007 Bern",
        "Währung",
        "Betrag",
        "CHF",
        "Annahmestelle",
        "Zahlteil",
        "Währung",
        "Betrag",
        "CHF",
        "Konto / Zahlbar an",
        "CH93 0076 2011 6238 5295 7",
        "Puzzle",
        "Belpstrasse 37",
        "3007 Bern",
        "Referenznummer",
        "00 00376 80338 90000 00000 00021",
        "Zahlbar durch",
        "Max Muster",
        "Belpstrasse 37",
        "3007 Bern"
      ]

      expect(text_with_position.map { _3 }).to eql invoice_text
    end


    it 'renders everything else regardless' do
      invoice_text = [[415, 529, "Rechnungsdatum: 15.06.2022"],
                      [57, 687, "Max Muster"],
                      [57, 674, "Belpstrasse 37"],
                      [57, 661, "3007 Bern"],
                      [57, 529, "Invoice"],
                      [57, 494, "Rechnungsnummer: 636980692-2"],
                      [364, 494, "Anzahl"],
                      [422, 494, "Preis"],
                      [465, 494, "Betrag"],
                      [515, 494, "MwSt."],
                      [404, 480, "Zwischenbetrag"],
                      [506, 480, "0.00 CHF"],
                      [404, 462, "Gesamtbetrag"],
                      [505, 462, "0.00 CHF"],
                      [57, 463, "Fällig bis:      01.08.2022"],
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
      expect(rows_with_text('Gesamtbetrag')).to include([400, 433, "Gesamtbetrag"])
      expect(rows_at_position(433)).to include([501, 433, "11.00 CHF"])

      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      InvoiceItem.create!(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: true)
      invoice.reload.recalculate!

      expect(rows_with_text('Subtotal')).to include([400, 451, 'Subtotal'])
      expect(rows_at_position(451)).to include([501, 451, "11.00 CHF"])

      expect(rows_with_text('Spende')).to include([400, 437, "Spende"])
      expect(rows_with_text('Gesamtbetrag')).to include([400, 419, "Gesamtbetrag"])
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
      invoice_text = [
        "Rechnungsdatum: 15.06.2022",
        "Max Muster",
        "Belpstrasse 37",
        "3007 Bern",
        "Invoice",
        "Rechnungsnummer: 636980692-2",
        "Anzahl",
        "Preis",
        "Betrag",
        "MwSt.",
        "Zwischenbetrag",
        "0.00 CHF",
        "Gesamtbetrag",
        "0.00 CHF",
        "Fällig bis:      01.08.2022",
        "Empfangsschein",
        "Konto / Zahlbar an",
        "CH93 0076 2011 6238 5295 7",
        "Puzzle",
        "Belpstrasse 37",
        "3007 Bern",
        "Zahlbar durch",
        "Max Muster",
        "Belpstrasse 37",
        "3007 Bern",
        "Währung",
        "Betrag",
        "CHF",
        "Annahmestelle",
        "Zahlteil",
        "Währung",
        "Betrag",
        "CHF",
        "Konto / Zahlbar an",
        "CH93 0076 2011 6238 5295 7",
        "Puzzle",
        "Belpstrasse 37",
        "3007 Bern",
        "Referenznummer",
        "00 00376 80338 90000 00000 00021",
        "Zahlbar durch",
        "Max Muster",
        "Belpstrasse 37",
        "3007 Bern",
      ]

      expect(text_with_position.map { _3 }).to eq invoice_text
    end

    it 'renders total when hide_total=false' do
      InvoiceItem.create!(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: false)
      invoice.reload.recalculate!
      expect(rows_with_text('Gesamtbetrag')).to include([400, 433, "Gesamtbetrag"])
      expect(rows_at_position(433)).to include([501, 433, "11.00 CHF"])

      full_text = subject.show_text.join("\n")
      expect(full_text).not_to include("Subtotal")
      expect(full_text).not_to include("Spende")
    end

    it 'renders subtotal and donation row when hide_total=true' do
      InvoiceItem.create!(invoice: invoice, name: 'dings', count: 1, unit_cost: 10, vat_rate: 10)
      invoice.update!(hide_total: true)
      invoice.reload.recalculate!
      expect(rows_with_text('Subtotal')).to include([400, 451, 'Subtotal'])
      expect(rows_at_position(451)).to include([501, 451, "11.00 CHF"])

      expect(rows_with_text('Spende')).to eq [[400, 437, "Spende"]]
      expect(rows_with_text('Gesamtbetrag')).to eq [[400, 419, "Gesamtbetrag"]]
    end
  end

  context 'rendered right' do
    before do
      invoice.group.letter_address_position = :right
      invoice.group.save!
    end

    it 'renders membership_card when true' do
      invoice.update!(membership_card: true, membership_expires_on: Date.parse('2022-10-01'))
      membership_card = [
        [57, 721, "Mitgliederausweis"],
        [57, 710, "42421"],
        [57, 699, "Bob Foo"],
        [222, 721, "Gültig bis"],
        [227, 710, "10.2022"]
      ]
      expect(text_with_position).to include(*membership_card)
    end

    it 'renders receiver address' do
      expect(text_with_position).to include([347, 687, "Max Muster"],
                                            [347, 674, "Belpstrasse 37"],
                                            [347, 661, "3007 Bern"])
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
      membership_card = [
        [346, 721, "Mitgliederausweis"],
        [346, 710, "42421"],
        [346, 699, "Bob Foo"],
        [511, 721, "Gültig bis"],
        [517, 710, "10.2022"]
      ]

      expect(text_with_position).to include(*membership_card)
    end

    it 'renders receiver address' do
      expect(text_with_position).to include([85, 690, "Max Muster"],
                                            [85, 677, "Belpstrasse 37"],
                                            [85, 664, "3007 Bern"])
    end
  end


  it 'renders invoice information to the right' do
    expect(text_with_position.find { _3 == 'Rechnungsdatum: 15.06.2022' }).to start_with(415, 529)
  end

  it 'renders invoice number as column label' do
    expect(text_with_position.find { _3.starts_with?('Rechnungsnummer') }).to end_with(["Rechnungsnummer: 636980692-2"])
  end

  it 'renders invoice due at below articles table' do
    due_at = text_with_position.find { _3.starts_with?('Fällig bis') }

    expect(due_at).to start_with(57, 463)
    expect(invoice.due_at).to eql Date.parse('2022-08-01')
    expect(due_at).to end_with "Fällig bis:      01.08.2022"
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
        expect(rows_with_text('Gesamtbetrag')).to include([400, 433, "Gesamtbetrag"])
        expect(rows_at_position(433)).to include([501, 433, "11.00 CHF"])

        full_text = subject.show_text.join("\n")
        expect(full_text).not_to include("Subtotal")
        expect(full_text).not_to include("Spende")
      end

      it 'renders partial payments' do
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

    context 'with hide_total=true' do
      before { invoice.update!(hide_total: true) }
      it 'renders subtotal and donation row' do
        expect(rows_with_text('Subtotal')).to include([400, 451, 'Subtotal'])
        expect(rows_at_position(451)).to include([501, 451, "11.00 CHF"])

        expect(rows_with_text('Spende')).to include([400, 437, "Spende"])
        expect(rows_with_text('Gesamtbetrag')).to include([400, 419, "Gesamtbetrag"])
      end

      it 'renders partial payments' do
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
