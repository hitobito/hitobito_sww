# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Sww::Event::ParticipationsController
  private

  def render_entries_pdf(participations)
    render_pdf(participations, group)
  end

  def generate_pdf(participations, group)
    super(participations.map(&:person)) if params[:label_format_id]

    Export::Pdf::Participations.render(participations, group)
  end
end
