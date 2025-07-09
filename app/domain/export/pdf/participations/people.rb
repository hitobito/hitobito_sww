# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Export::Pdf::Participations
  class People < ::Export::Pdf::List::People
    def initialize(pdf, contactables, group, event)
      @event = event
      super(pdf, contactables, group)
    end

    private

    def table_header
      super + [
        I18n.t("activerecord.attributes.event/participation.additional_information"), # Bemerkungen
        I18n.t("activerecord.models.event/role.other") # Anlass Rollen
      ]
    end

    def person_row(participation)
      super(participation.person) + [
        participation.additional_information,
        formatted_roles(participation)
      ]
    end

    def formatted_roles(participation)
      participation.roles.map(&:to_s).join(", ")
    end
  end
end
