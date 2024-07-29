#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::SelfRegistrationHelper
  def link_to_sww_privacy
    link_to(
      t("groups.self_registration.main_person.privacy_link_name"),
      t("groups.self_registration.main_person.privacy_link"),
      target: "_blank", rel: "noopener"
    )
  end

  def link_to_sww_terms_of_use
    link_to(
      t("groups.self_registration.main_person.terms_of_use_link_name"),
      t("groups.self_registration.main_person.terms_of_use_link"),
      target: "_blank", rel: "noopener"
    )
  end
end
