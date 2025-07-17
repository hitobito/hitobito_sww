# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Export::Tabular::People
  class ParticipationsListRow < Export::Tabular::People::ParticipationRow
    def phone_mobile
      entry.phone_numbers.find_by(label: "Mobil").try(:number)
    end

    def full_address
      [
        entry.address.to_s.strip.presence,
        [entry.zip_code, entry.town].compact.join(" ").squish.presence
      ].compact.join(", ")
    end
  end
end
