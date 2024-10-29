# frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Tabular::People::PersonRow
  extend ActiveSupport::Concern

  def roles
    entry.roles.map do |role|
      role_validity = [
        I18n.l(role.created_at.to_date),
        role.archived_at.present? && I18n.l(role.archived_at.to_date) || ""
      ]
      "#{role} #{role.group.with_layer.join(" / ")} (#{role_validity.join("-")})"
    end.join(", ")
  end
end
