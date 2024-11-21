#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::LayoutHelper
  extend ActiveSupport::Concern

  included do
    def render_header_logo?
      case params.permit(:controller, :action, :oauth).to_h
      in controller: "groups/self_registration", action: "show"
        false
      in controller: "devise/hitobito/sessions", action: "new"
        params[:oauth].blank?
      else
        true
      end
    end
  end
end
