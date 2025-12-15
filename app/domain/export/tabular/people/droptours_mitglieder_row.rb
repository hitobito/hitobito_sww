# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Export::Tabular::People
  class DroptoursMitgliederRow < Export::Tabular::Row
    attr_reader :fachorganisation

    delegate :id, :name, to: :fachorganisation, prefix: true

    def initialize(entry, fachorganisation, format = nil)
      @fachorganisation = fachorganisation
      super(entry, format)
    end

    # Geburtsdatum im Format dd.mm.yyyy
    def birthday
      entry.birthday&.strftime("%d.%m.%Y")
    end

    # Land als zwei-Buchstaben-Kürzel, z.B. DE, FR etc.; wenn Schweiz dann leer
    def country
      entry.country unless entry.country == "CH"
    end

    # Eintrittsdatum der allerersten Mitgliederrolle dieser Person,
    # in derselben Fachorganisation welche exportiert wird
    def date_of_joining
      entry.roles_unscoped.select do |role|
        role.is_a?(DroptoursMitglieder::MITGLIED_ROLE_TYPE) &&
          role.group.layer_group_id == fachorganisation.id
      end.map { |r| r.start_on || r.created_at.to_date }.min
    end

    def email
      entry.email.presence || entry.additional_emails.first&.email
    end

    # Mögliche Werte: Weiblich / Männlich / Andere
    # def gender
    #   case entry.gender
    #   when "w" then "Weiblich"
    #   when "m" then "Männlich"
    #   else "Andere"
    #   end
    # end

    # Sprache Korrespondenzsprache der Person.
    # Mögliche Werte: D / F / ITS
    # (Englisch als Korrespondenzsprache wird für den SAC noch in separatem Ticket deaktiviert)
    # def language
    #   case entry.language
    #   when "de" then "D"
    #   when "fr" then "F"
    #   when "it" then "ITS"
    #   else entry.language.upcase
    #   end
    # end

    def phone_number_landline
      entry.phone_numbers.find { _1.label == "Privat" }&.number
    end

    def phone_number_mobile
      entry.phone_numbers.find { _1.label == "Mobil" }&.number
    end
  end
end
