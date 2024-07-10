# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww
  module Export
    module Pdf
      module Invoice
        # This class combines a payment slip with a logo. If the logo and
        # the payment slip do not fit on the current page, a new page
        # is created. The logo and the payment slip are always
        # rendered together.
        class PaymentSlipWithLogo < ::Export::Pdf::Section
          attr_reader :options

          def render
            # use a new page if the logo and the payment slip
            # do not fit below the current cursor
            pdf.start_new_page if cursor < height
            render_logo
            # manually move cursor to the bottom of the logo to ensure
            # that the payment slip will not start on a new page
            pdf.move_cursor_to payment_slip.height
            payment_slip.render
          end

          private

          alias_attribute :invoice, :model

          def height
            logo.height + payment_slip.height
          end

          def logo
            @logo ||= ::Export::Pdf::Logo.new(
              pdf,
              invoice.invoice_config.logo,
              image_width: ::Export::Pdf::Invoice::LOGO_WIDTH,
              image_height: ::Export::Pdf::Invoice::LOGO_HEIGHT,
              position: :left,
              **options
            ).with_padding(
              top: LOGO_PADDING_TOP,
              bottom: LOGO_PADDING_BOTTOM
            )
          end

          def payment_slip
            @payment_slip ||= ::Export::Pdf::Invoice::PaymentSlipQr.new(pdf, invoice, options)
          end

          def render_logo
            bounding_box([0, height], width: bounds.width, height: height) do
              logo.render
            end
          end
        end
      end
    end
  end
end
