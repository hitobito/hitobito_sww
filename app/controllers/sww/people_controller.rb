#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::PeopleController
  extend ActiveSupport::Concern

  SELF_EDIT_RESTRICTED_ATTRS = [:first_name, :last_name, :email].freeze

  prepended do
    self.permitted_attrs += [:custom_salutation, :magazin_abo_number,
      :name_add_on, :title]
  end

  # Removes restricted attributes from permitted_attrs when editing own profile.
  # This prevents self-submitted changes via strong parameters and is also used
  # in the view partials (via controller.permitted_attrs) to render restricted
  # fields as plaintext instead of input fields.
  def permitted_attrs
    return super unless entry.id == current_user.id

    super - SELF_EDIT_RESTRICTED_ATTRS
  end
end
