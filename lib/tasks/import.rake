# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

# rubocop:disable Metrics/BlockLength, Layout/LineLength, Rails/SkipsModelValidations
namespace :import do
  desc "Convert sww profile cms profile input file from xlsx to csv"
  file "tmp/mod_profile.csv" => ["data/mod_profile.xlsx"] do
    puts "Converting xlsx .."
    `in2csv -d ';' "data/mod_profile.xlsx"  > tmp/mod_profile.csv`
  end

  desc "Import mod profile"
  task mod_profile_import: ["tmp/mod_profile.csv", :environment] do
    ModProfileImport::Runner.new.run
  end
end
# rubocop:enable Metrics/BlockLength, Layout/LineLength, Rails/SkipsModelValidations
