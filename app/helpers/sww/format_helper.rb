# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::FormatHelper
  extend ActiveSupport::Concern

  def signed_number(value)
    format("%+d", value)
  end

  def net_change_arrow(value)
    if value.positive?
      "↗"
    elsif value.negative?
      "↘"
    else
      "→"
    end
  end
end
