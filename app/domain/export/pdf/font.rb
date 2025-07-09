# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Export::Pdf
  class Font
    def initialize(pdf)
      @pdf = pdf
    end

    def customize
      @pdf.font_families.update("cardo" => cardo_font_family)
      @pdf.font "cardo"
      @pdf.font_size 10

      @pdf
    end

    def cardo_font_family
      {
        normal: {file: font_path.join("cardo-regular-104s.ttf")},
        italic: {file: font_path.join("cardo-italic-099.ttf")},
        bold: {file: font_path.join("cardo-bold-101.ttf")}
      }
    end

    def font_path
      @font_path ||= HitobitoSww::Wagon.root.join("app", "javascript", "fonts")
    end
  end
end
