# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Export::Pdf::Participations
  class People < ::Export::Pdf::List::People
    private

    def table_header
      super + [
        I18n.t('activerecord.attributes.event/participation.additional_information')
      ]
    end

    def person_row(participation)
      super(participation.person) + [
        participation.additional_information
      ]
    end
  end
end
