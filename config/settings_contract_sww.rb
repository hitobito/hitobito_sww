# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

class SettingsContractSww < SettingsContract
  params do
    required(:droptours_export).schema do
      required(:sftp_config).array(:hash) do
        required(:fachorganisation_id).filled(:integer)

        # Dynamically declare SFTP config keys from base contract
        Sftp::ConfigContract.schema.key_map.map(&:id).each do |key|
          optional(key)
        end
      end
    end
  end

  rule("droptours_export.sftp_config").each do |index:|
    result = Sftp::ConfigContract.new.call(value)

    result.errors.each do |error|
      # error.path is an array like [:host] or [:password]
      # Use key with index to target specific array element
      field = error.path.first
      key([:droptours_export, :sftp_config, index, field]).failure(error.text)
    end
  end
end
