#  frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::TagListsHelper
  extend ActiveSupport::Concern

  included do
    def format_tag_category(category)
      case category
      when :other
        t('tags.categories.other')
      when :category_validation
        t('tags.categories.validation')
      when :abo
        t('tags.categories.abo')
      when :category
        t('tags.categories.category')
      else
        category
      end
    end
  end
end
