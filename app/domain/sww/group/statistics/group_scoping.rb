# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Sww::Group::Statistics::GroupScoping
  extend ActiveSupport::Concern

  included do
    self.permitted_params += [:include_sublayers]
  end

  def include_sublayers?
    filter_params[:include_sublayers].to_s != "false"
  end

  private

  def group_ids
    @group_ids ||= if include_sublayers?
      scoping_root.self_and_descendants.pluck(:id)
    else
      scoping_root.groups_in_same_layer.pluck(:id)
    end
  end
end
