# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Export::Pdf
  module Participations
    class Runner < Export::Pdf::List::Runner
      def render(contactables, group, event)
        pdf = Export::Pdf::Document.new(margin: 1.cm, page_layout: :landscape).pdf
        sections.each { |section| section.new(pdf, contactables, group, event).render }
        footer(pdf)
        pdf.render
      end

      private

      def sections
        [Export::Pdf::Participations::Header, Export::Pdf::Participations::People]
      end
    end

    def self.render(participations, group, event)
      Export::Pdf::Participations::Runner.new.render(participations, group, event)
    end
  end
end
