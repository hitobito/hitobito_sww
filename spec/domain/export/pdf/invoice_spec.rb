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
  end

  def build_invoice(**attrs)
    Invoice.new(**attrs.reverse_merge(group: groups(:top_layer)))
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
          displayed_height: 18_912.618,
          displayed_width: 108_763.0,
          height: 417,
          width: 1000,
          x: 56.693,
          y: 739.843
        )
      end

      it 'with logo_position=right it renders logo on the right' do
        invoice.invoice_config.update(logo_position: :right)
        expect(image_positions).to have(2).items # logo and qr code
        expect(image_positions.first).to match(
          displayed_height: 18_912.618,
          displayed_width: 108_763.0,
          height: 417,
          width: 1000,
          x: 429.824,
          y: 739.843
        )
      end

      it 'with logo_position=above_payment_slip it renders logo above the payment slip' do
        invoice.invoice_config.update(logo_position: :above_payment_slip)
        expect(image_positions).to have(2).items # logo and qr code
        expect(image_positions.first).to match(
          displayed_height: 18_912.618,
          displayed_width: 108_763.0,
          height: 417,
          width: 1000,
          x: 56.693,
          y: 314.646
        )
      end
    end
  end
end
