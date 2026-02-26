#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Event::ParticipationContactDatasController
  extend ActiveSupport::Concern

  SELF_EDIT_RESTRICTED_ATTRS = Sww::PeopleController::SELF_EDIT_RESTRICTED_ATTRS

  # Removes restricted attributes from permitted_attrs when editing own contact
  # data. This prevents self-submitted changes via strong parameters and is used
  # in the view partials to render restricted fields
  # as plaintext instead of input fields.
  def permitted_attrs
    return super unless person.id == current_user.id

    super - SELF_EDIT_RESTRICTED_ATTRS
  end

  # Re-injects existing person values for restricted attributes that were
  # stripped by permitted_attrs. This is needed because ParticipationContactData
  # validates mandatory attrs (first_name, last_name, email) against model_params
  # — without the existing values, validation would fail with blank errors.
  def model_params
    return super unless person.id == current_user.id

    super.merge(
      person.attributes.with_indifferent_access.slice(*SELF_EDIT_RESTRICTED_ATTRS)
    )
  end
end
