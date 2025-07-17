# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Export::Tabular::People::ParticipationsList < Export::Tabular::People::ParticipationsFull
  self.model_class = ::Event::Participation
  self.row_class = ::Export::Tabular::People::ParticipationsListRow

  def build_attribute_labels
    {
      first_name: Person.human_attribute_name(:first_name),
      last_name: Person.human_attribute_name(:last_name),
      email: Person.human_attribute_name(:email),
      full_address: Person.human_attribute_name(:address),
      phone_mobile: "#{PhoneNumber.model_name.human} (#{PhoneNumber.translate_label("Mobil")})",
      participation_additional_information: Event::Participation.human_attribute_name(:additional_information)
    }.merge(questions_labels)
  end
end
