# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::EventParticipationsExportJob
  private

  def exporter
    if @options[:participations_list] && ability.can?(:show_details, entries.build)
      Export::Tabular::People::ParticipationsList
    else
      super
    end
  end
end
