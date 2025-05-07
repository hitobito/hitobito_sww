# encoding: utf-8

#  Copyright (c) 2012-2018, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Pdf::Invoice do
  include PdfHelpers

  let(:invoice) { invoices(:invoice).tap { |i| i.update(payment_slip: :qr) } }
  let(:sent)    { invoices(:sent) }

  let(:pdf) { described_class.render(invoice, payment_slip: true, articles: true) }

  before do
    invoice.update!(
      payment_slip: :qr,
      payee: "Hitobito AG\nHans Gerber\nSwitzerland",
      iban: 'CH93 0076 2011 6238 5295 7'
    )
    invoice.invoice_config.update!(separators: false)
    InvoiceItem.create!(name: "pens", unit_cost: 10, vat_rate: 10, count: 2, invoice: invoice)
    invoice.reload
  end

  def build_invoice(**attrs)
    Invoice.new(**attrs.reverse_merge(group: groups(:top_layer)))
  end

  it "does render issued_at behind sequence_number" do
    invoice.update!(issued_at: Date.new(2025, 01, 01))
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
      [14, 276, "Empfangsschein"],
      [14, 251, "Konto / Zahlbar an"],
      [14, 239, "CH93 0076 2011 6238 5295 7"],
      [14, 228, "Hitobito AG"],
      [14, 216, "Hans Gerber"],
      [14, 205, "Switzerland"],
      [14, 173, "Zahlbar durch"],
      [14, 161, "Max Muster"],
      [14, 150, "Belpstrasse 37"],
      [14, 138, "3007 Bern"],
      [14, 89, "Währung"],
      [71, 89, "Betrag"],
      [14, 78, "CHF"],
      [71, 78, "22.00"],
      [105, 39, "Annahmestelle"],
      [190, 276, "Zahlteil"],
      [190, 89, "Währung"],
      [247, 89, "Betrag"],
      [190, 78, "CHF"],
      [247, 78, "22.00"],
      [346, 278, "Konto / Zahlbar an"],
      [346, 266, "CH93 0076 2011 6238 5295 7"],
      [346, 255, "Hitobito AG"],
      [346, 243, "Hans Gerber"],
      [346, 232, "Switzerland"],
      [346, 211, "Referenznummer"],
      [346, 200, "00 00376 80338 90000 00000 00021"],
      [346, 178, "Zahlbar durch"],
      [346, 167, "Max Muster"],
      [346, 155, "Belpstrasse 37"],
      [346, 144, "3007 Bern"]
    ]
    invoice_text.each_with_index do |text, i|
      expect(text_with_position[i]).to eq(text)
    end
  end

  it "does not render issued_at behind_sequence_number when issued_at is not set" do
    invoice_text = [
      [57, 687, "Max Muster"],
      [57, 674, "Belpstrasse 37"],
      [57, 661, "3007 Bern"],
      [57, 529, "Invoice"],
      [57, 494, "Rechnungsnummer: 636980692-2"],
      [364, 494, "Anzahl"],
      [422, 494, "Preis"],
      [465, 494, "Betrag"],
      [515, 494, "MwSt."],
      [57, 479, "pens"],
      [384, 480, "2"],
      [419, 480, "10.00"],
      [514, 480, "10.0 %"],
      [401, 466, "Zwischenbetrag"],
      [502, 466, "20.00 CHF"],
      [401, 451, "MwSt."],
      [506, 451, "2.00 CHF"],
      [401, 433, "Gesamtbetrag"],
      [505, 433, "0.00 CHF"],
      [14, 276, "Empfangsschein"],
      [14, 251, "Konto / Zahlbar an"],
      [14, 239, "CH93 0076 2011 6238 5295 7"],
      [14, 228, "Hitobito AG"],
      [14, 216, "Hans Gerber"],
      [14, 205, "Switzerland"],
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
      [346, 255, "Hitobito AG"],
      [346, 243, "Hans Gerber"],
      [346, 232, "Switzerland"],
      [346, 211, "Referenznummer"],
      [346, 200, "00 00376 80338 90000 00000 00021"],
      [346, 178, "Zahlbar durch"],
      [346, 167, "Max Muster"],
      [346, 155, "Belpstrasse 37"],
      [346, 144, "3007 Bern"]
    ]
    invoice_text.each_with_index do |text, i|
      expect(text_with_position[i]).to eq(text)
    end
  end

  it "renders created at of latest reminder when reminder exists as invoice date" do
    invoice.update!(issued_at: Date.new(2025, 01, 01), due_at: 5.days.from_now, state: "sent")
    PaymentReminder.create!(level: 1, due_at: 10.days.from_now, invoice: invoice, created_at: Date.new(2025, 06, 06))
    invoice_text = [
      [459, 529, "Datum: 06.06.2025"],
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
      [57, 434, "Fällig bis:      17.05.2025"],
      [14, 276, "Empfangsschein"],
      [14, 251, "Konto / Zahlbar an"],
      [14, 239, "CH93 0076 2011 6238 5295 7"],
      [14, 228, "Hitobito AG"],
      [14, 216, "Hans Gerber"],
      [14, 205, "Switzerland"],
      [14, 173, "Zahlbar durch"],
      [14, 161, "Max Muster"],
      [14, 150, "Belpstrasse 37"],
      [14, 138, "3007 Bern"],
      [14, 89, "Währung"],
      [71, 89, "Betrag"],
      [14, 78, "CHF"],
      [71, 78, "22.00"],
      [105, 39, "Annahmestelle"],
      [190, 276, "Zahlteil"],
      [190, 89, "Währung"],
      [247, 89, "Betrag"],
      [190, 78, "CHF"],
      [247, 78, "22.00"],
      [346, 278, "Konto / Zahlbar an"],
      [346, 266, "CH93 0076 2011 6238 5295 7"],
      [346, 255, "Hitobito AG"],
      [346, 243, "Hans Gerber"],
      [346, 232, "Switzerland"],
      [346, 211, "Referenznummer"],
      [346, 200, "00 00376 80338 90000 00000 00021"],
      [346, 178, "Zahlbar durch"],
      [346, 167, "Max Muster"],
      [346, 155, "Belpstrasse 37"],
      [346, 144, "3007 Bern"]
    ]
    invoice_text.each_with_index do |text, i|
      expect(text_with_position[i]).to eq(text)
    end
  end

  it 'is a SWW::Export::Pdf::Invoice' do
    expect(described_class.ancestors).to include(Sww::Export::Pdf::Invoice)
  end

  context 'logo' do
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
