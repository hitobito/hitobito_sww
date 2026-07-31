# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::PersonResource
  extend ActiveSupport::Concern

  included do
    attribute :title, :string
    attribute :magazin_abo_number, :integer, readable: :show_details_on_person?
    attribute :sww_cms_profile_id, :integer, writable: false,
      readable: :show_details_on_person?
    attribute :updated_at, :datetime, writable: false

    belongs_to :updated_by,
      foreign_key: :updater_id,
      resource: PersonResource,
      writable: false
  end

  # For attributes that are not viewable in the UI on an event participation of this person
  def show_details_on_person?(model_instance)
    can?(:show_details, model_instance)
  end
end
