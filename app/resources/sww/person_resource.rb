#  frozen_string_literal: true

#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::PersonResource
  extend ActiveSupport::Concern

  included do
    attribute :title, :string
    attribute :custom_salutation, :string
    attribute :name_add_on, :string
    attribute :magazin_abo_number, :integer
    attribute :sww_cms_profile_id, :integer, writable: false
    attribute :updated_at, :datetime, writable: false

    extra_attribute :layer_group_name, :string, writable: false do
      @object.layer_group&.display_name
    end
    on_extra_attribute :layer_group_name do |scope|
      scope.includes(:primary_group)
    end

    belongs_to :updated_by,
               foreign_key: :updater_id,
               resource: PersonResource,
               writable: false
  end
end
