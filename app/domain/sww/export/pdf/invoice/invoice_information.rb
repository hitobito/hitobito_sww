# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module Sww::Export::Pdf::Invoice::InvoiceInformation
  extend ActiveSupport::Concern

  included do
    def render
      bounding_box([290, 640], width: bounds.width, height: 80) do
        table(information, cell_style: { borders: [], padding: [1, 20, 0, 0] })
      end
    end
  end
end
