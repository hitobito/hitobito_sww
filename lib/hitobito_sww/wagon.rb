# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


module HitobitoSww
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W[
      #{config.root}/app/abilities
      #{config.root}/app/domain
      #{config.root}/app/jobs
    ]

    config.to_prepare do
      # extend application classes here
      Group.include Sww::Group
      Person.include Sww::Person

      Export::Pdf::Invoice::ReceiverAddress.include Sww::Export::Pdf::Invoice::ReceiverAddress
      Export::Pdf::Invoice::InvoiceInformation.include Sww::Export::Pdf::Invoice::InvoiceInformation
      Export::Pdf::Invoice::Articles.prepend Sww::Export::Pdf::Invoice::Articles

      TagListsHelper.include Sww::TagListsHelper

      PeopleController.permitted_attrs += [:custom_salutation, :magazin_abo_number,
                                           :name_add_on, :title]
    end

    initializer 'sww.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'sww.add_inflections' do |_app|
      ActiveSupport::Inflector.inflections do |inflect|
        # inflect.irregular 'census', 'censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end
