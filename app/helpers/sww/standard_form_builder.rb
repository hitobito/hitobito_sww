# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::StandardFormBuilder
  def positive_number_field(attr, html_options = {})
    html_options[:size] ||= 10
    html_options[:class] ||= "span2"
    html_options[:pattern] ||= "([0-9]*[.])?[0-9]+"

    text_field(attr, html_options)
  end
end
