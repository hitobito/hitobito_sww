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
      GroupSetting.include Sww::GroupSetting
      Group.include Sww::Group
      Person.include Sww::Person
      PersonResource.include Sww::PersonResource

      Export::Pdf::AddressRenderers.include Sww::Export::Pdf::AddressRenderers
      Export::Pdf::Invoice.prepend Sww::Export::Pdf::Invoice
      Export::Pdf::Invoice::ReceiverAddress.prepend Sww::Export::Pdf::Invoice::ReceiverAddress
      Export::Pdf::Invoice::InvoiceInformation.prepend Sww::Export::Pdf::Invoice::InvoiceInformation
      Export::Pdf::Invoice::Articles.prepend Sww::Export::Pdf::Invoice::Articles

      Export::Tabular::People::PeopleFull.prepend Sww::Export::Tabular::People::PeopleFull
      Export::Pdf::Messages::Letter.prepend Sww::Export::Pdf::Messages::Letter

      TagListsHelper.include Sww::TagListsHelper
      StandardFormBuilder.include Sww::StandardFormBuilder

      PeopleController.permitted_attrs += [:custom_salutation, :magazin_abo_number,
                                           :name_add_on, :title]
      InvoicesController.permitted_attrs += [:membership_card, :membership_expires_on]

      # Since permitted_attrs are an array, it's really hard to expand nested attrs
      # rubocop:disable Metrics/LineLength
      invoice_lists_invoice_permitted_attrs_hash = InvoiceListsController.permitted_attrs.find { |attr| attr.is_a?(Hash) && attr.keys.include?(:invoice) }
      invoice_lists_invoice_permitted_attrs = invoice_lists_invoice_permitted_attrs_hash[:invoice]
      invoice_lists_invoice_permitted_attrs_hash.merge!(invoice: invoice_lists_invoice_permitted_attrs + [:membership_card, :membership_expires_on])
      # rubocop:enable Metrics/LineLength

      MessagesController::PERMITTED_LETTER_ATTRS += [:membership_card,
                                                     :membership_expires_on]
      MessagesController::PERMITTED_INVOICE_LETTER_ATTRS += [:membership_card,
                                                             :membership_expires_on]
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
