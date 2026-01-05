# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module Export
  class DroptoursUploadConfig
    FILE_PATH = Rails.root.join("config", "droptours-upload-config.yml")

    class << self
      def instance
        @instance ||= new(FILE_PATH)
      end
    end

    def initialize(path)
      @path = path
    end

    def config
      @config ||= load.freeze
    end

    private

    def load
      return {} unless File.exist?(@path)
      YAML.safe_load_file(@path, permitted_classes: [Symbol]).tap do |data|
        return {} if data.nil?

        raise "#{@path} must contain a YAML hash" unless data.is_a?(Hash)
      end
    end
  end
end
