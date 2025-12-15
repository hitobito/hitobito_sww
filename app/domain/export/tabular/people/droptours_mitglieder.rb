# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Export::Tabular::People
  class DroptoursMitglieder < Export::Tabular::Base
    self.model_class = Person
    self.row_class = DroptoursMitgliederRow

    FACHORGANISATION = Group::Fachorganisation
    MITGLIEDER_GROUP_TYPE = Group::Mitglieder
    MITGLIED_ROLE_TYPE = Group::Mitglieder::Aktivmitglied

    attr_reader :fachorganisation

    def initialize(fachorganisation, *, **)
      unless fachorganisation.is_a?(FACHORGANISATION)
        raise ArgumentError, "Argument must be a Fachorganisation"
      end

      @fachorganisation = fachorganisation
      super(mitglieder)
    end

    def attributes # rubocop:disable Metrics/MethodLength
      [
        :id,
        :member_number,
        :last_name,
        :first_name,
        :address_care_of,
        :address,
        :postbox,
        :zip_code,
        :town,
        :country,
        :birthday,
        :phone_number_landline,
        :phone_number_mobile,
        :email,
        :gender,
        :language,
        :date_of_joining,
        :additional_information
      ]
    end

    def mitglieder
      Person
        .joins(:roles)
        .where(roles: {
          group_id: export_groups.map(&:id),
          type: MITGLIED_ROLE_TYPE.sti_name
        })
        .includes(:phone_numbers, :additional_emails, roles_unscoped: :group)
        .distinct
    end

    def export_groups
      MITGLIEDER_GROUP_TYPE
        .where(layer_group_id: fachorganisation.id)
        .select(&:droptours_export)
    end

    # We use attribute names as labels directly
    def human_attribute(attr) = attr

    private

    # Override to pass fachorganisation to row
    def row_for(entry, format = nil)
      row_class.new(entry, fachorganisation, format)
    end
  end
end
