# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Export::Pdf::Participations
  class Header < ::Export::Pdf::List::Header
    def initialize(pdf, contactables, group, event)
      @event = event
      super(pdf, contactables, group)
    end

    private

    def pdf_title
      @event.name
    end
  end
end
