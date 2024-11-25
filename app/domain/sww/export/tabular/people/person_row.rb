# frozen_string_literal: true

#  Copyright (c) 2012-2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Tabular::People::PersonRow
  extend ActiveSupport::Concern

  def roles
    entry.roles.map do |role|
      start_on = role.start_on.present? && I18n.l(role.start_on.to_date) || ""
      end_on = role.end_on.present? && I18n.l(role.end_on.to_date) || ""
      "#{role.to_s(:short)} #{role.group.with_layer.join(" / ")} (#{[start_on, end_on].join("-")})"
    end.join(", ")
  end
end
