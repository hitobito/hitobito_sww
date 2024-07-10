# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Export::Pdf
  module Participations
    class Runner < Export::Pdf::List::Runner
      private

      def setup_pdf
        Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: 1.cm)
      end

      def sections
        [Export::Pdf::List::Header, Export::Pdf::Participations::People]
      end
    end

    def self.render(participations, group)
      Export::Pdf::Participations::Runner.new.render(participations, group)
    end
  end
end
