# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module HitobitoSww
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement ">= 0"

    # Add a load path for this specific wagon
    config.autoload_paths += %W[
      #{config.root}/app/abilities
      #{config.root}/app/domain
      #{config.root}/app/jobs
    ]

    config.to_prepare do # rubocop:disable Metrics/BlockLength
      # rubocop:disable Metrics/LineLength
      # extend application classes here
      InvoiceAbility.include Sww::InvoiceAbility
      InvoiceConfig.prepend Sww::InvoiceConfig
      Invoice::STATES_PAYABLE << "payed" << "excess"

      Event.include Sww::Event
      Event::Question.include Sww::Event::Question
      EventAbility.include Sww::EventAbility
      Group.include Sww::Group
      Person.include Sww::Person

      Person::Address.prepend Sww::Person::Address

      Wizards::Steps::NewUserForm.prepend Sww::Wizards::Steps::NewUserForm

      PersonResource.include Sww::PersonResource

      Export::Pdf::AddressRenderers.include Sww::Export::Pdf::AddressRenderers
      Export::Pdf::Invoice.prepend Sww::Export::Pdf::Invoice
      Export::Pdf::Invoice::ReceiverAddress.prepend Sww::Export::Pdf::Invoice::ReceiverAddress
      Export::Pdf::Invoice::InvoiceInformation.prepend Sww::Export::Pdf::Invoice::InvoiceInformation
      Export::Pdf::Invoice::Articles.prepend Sww::Export::Pdf::Invoice::Articles
      Export::Pdf::Invoice::PaymentSlipQr.include Sww::Export::Pdf::Invoice::PaymentSlipQr
      Export::Tabular::Invoices::EvaluationList.include Sww::Export::Tabular::Invoices::EvaluationList

      Export::Tabular::People::PeopleFull.prepend Sww::Export::Tabular::People::PeopleFull
      Export::Tabular::People::PersonRow.prepend Sww::Export::Tabular::People::PersonRow
      Export::Pdf::Messages::Letter.prepend Sww::Export::Pdf::Messages::Letter
      Export::Pdf::Messages::Letter::Header.prepend Sww::Export::Pdf::Messages::Letter::Header

      Export::Pdf::Participation::Runner.prepend Sww::Export::Pdf::Participation::Runner

      Dropdown::PeopleExport.prepend Sww::Dropdown::PeopleExport
      Export::EventParticipationsExportJob.prepend Sww::Export::EventParticipationsExportJob

      PaperTrail::VersionDecorator.prepend Sww::PaperTrail::VersionDecorator

      LayoutHelper.include Sww::LayoutHelper
      TagListsHelper.include Sww::TagListsHelper
      StandardFormBuilder.include Sww::StandardFormBuilder

      Invoices::EvaluationsController.prepend Sww::Invoices::EvaluationsController

      JsonApiController.include Sww::JsonApiController

      Event::ParticipationsController.prepend Sww::Event::ParticipationsController

      PersonResource.include Sww::PersonResource
      Oauth::ProfilesController.prepend Sww::Oauth::ProfilesController
      GroupsController.permitted_attrs += [:event_sender]
      PeopleController.permitted_attrs += [:custom_salutation, :magazin_abo_number,
        :name_add_on, :title]
      InvoicesController.permitted_attrs += [:membership_card, :membership_expires_on]
      InvoiceConfigsController.permitted_attrs += [:separators]

      Event::ParticipationMailer.prepend Sww::Event::ParticipationMailer
      Event::RegisterMailer.prepend Sww::Event::RegisterMailer

      # Since permitted_attrs are an array, it's really hard to expand nested attrs
      invoice_lists_invoice_permitted_attrs_hash = InvoiceListsController.permitted_attrs.find { |attr| attr.is_a?(Hash) && attr.keys.include?(:invoice) }
      invoice_lists_invoice_permitted_attrs = invoice_lists_invoice_permitted_attrs_hash[:invoice]
      invoice_lists_invoice_permitted_attrs_hash.merge!(invoice: invoice_lists_invoice_permitted_attrs + [:membership_card, :membership_expires_on])

      MailingListAbility.include Sww::MailingListAbility

      MessagesController::PERMITTED_LETTER_ATTRS.push(:membership_card,
        :membership_expires_on)
      MessagesController::PERMITTED_INVOICE_LETTER_ATTRS.push(:membership_card,
        :membership_expires_on)
      Role::Permissions << :support << :complete_finance
      # rubocop:enable Metrics/LineLength
    end

    initializer "sww.add_settings" do |_app|
      Settings.add_source!(File.join(paths["config"].existent, "settings.yml"))
      Settings.reload!
    end

    initializer "sww.add_inflections" do |_app|
      ActiveSupport::Inflector.inflections do |inflect|
        # inflect.irregular 'census', 'censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join("db", "seeds")
      ENV["NO_ENV"] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end
  end
end
