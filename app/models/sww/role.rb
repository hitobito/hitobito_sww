# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Role
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:created_at, :deleted_at]

    validates :created_at, presence: true, if: :deleted_at

    validates_date :created_at,
                   if: :deleted_at,
                   on_or_before: :deleted_at,
                   on_or_before_message: :cannot_be_later_than_deleted_at

    validates_date :created_at,
                   allow_nil: true,
                   on_or_before: -> { Time.zone.today },
                   on_or_before_message: :cannot_be_later_than_today
  end

end
