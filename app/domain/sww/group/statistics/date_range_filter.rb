# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Sww::Group::Statistics::DateRangeFilter
  extend ActiveSupport::Concern

  included do
    self.permitted_params += [:from, :to]

    validates_date :from, allow_blank: true
    validates_date :to, allow_blank: true
    validates_date :to, on_or_after: :from,
      on_or_after_message: :date_range_invalid,
      if: -> { filter_params[:from].present? && errors[:to].none? }
  end

  def from
    filter_params[:from]
  end

  def to
    filter_params[:to]
  end

  def from_date
    @from_date ||= parse_date(filter_params[:from]) || Time.zone.today.beginning_of_year
  end

  def to_date
    @to_date ||= parse_date(filter_params[:to]) || Time.zone.today.end_of_year
  end
end
