#  frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

Graphiti.configure do |config|
  current_dirname = File.dirname(__FILE__)
  config.schema_path = Pathname.new(current_dirname).join('../../spec/support/graphiti/schema.json')
end
