# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe InvoiceAbility do
  subject { Ability.new(role.person.reload) }

  context "with complete_finance permission" do
    let(:role) {
      Fabricate(Group::SchweizerWanderwege::Support.sti_name.to_sym,
        group: groups(:schweizer_wanderwege))
    }

    Group.where(type: Group.all_types.select(&:layer).map(&:sti_name)).each do |layer|
      before do
        layer.send(:create_invoice_config)
        layer.invoice_config.update(sequence_number: "1")
      end

      context "on invoice" do
        let(:invoice) {
          Fabricate(:invoice, group: layer, recipient_email: "member@example.hitobito.com")
        }

        [:show, :create, :edit, :update, :destroy].each do |action|
          it "can #{action} in #{layer.name}" do
            is_expected.to be_able_to(action, invoice)
          end
        end
      end

      context "on invoice list" do
        let(:invoice_list) { InvoiceList.create(group: layer) }

        [:update, :destroy, :create, :index_invoices].each do |action|
          it "can #{action} in #{layer.name}" do
            is_expected.to be_able_to(action, invoice_list)
          end
        end
      end

      context "on invoice article" do
        let(:invoice_article) { InvoiceArticle.create(group: layer, name: "Membership", number: 1) }

        [:show, :new, :create, :edit, :update, :destroy].each do |action|
          it "can #{action} in #{layer.name}" do
            is_expected.to be_able_to(action, invoice_article)
          end
        end
      end

      context "on invoice config" do
        let(:invoice_config) { layer.invoice_config }

        [:show, :edit, :update].each do |action|
          it "can #{action} in #{layer.name}" do
            is_expected.to be_able_to(action, invoice_config)
          end
        end
      end

      context "on payment" do
        let(:invoice) {
          Fabricate(:invoice, group: layer, recipient_email: "member@example.hitobito.com")
        }
        let(:payment) { Payment.new(invoice: invoice, amount: 10) }

        [:create].each do |action|
          it "can #{action} in #{layer.name}" do
            is_expected.to be_able_to(action, payment)
          end
        end
      end

      context "on payment reminder" do
        let(:invoice) {
          Fabricate(:invoice, group: layer,
            recipient_email: "member@example.hitobito.com",
            state: :issued,
            invoice_items: [InvoiceItem.new(name: "Membership",
                                            # rubocop:todo Layout/ArgumentAlignment
                                            count: 1,
                                            # rubocop:enable Layout/ArgumentAlignment
                                            # rubocop:todo Layout/ArgumentAlignment
                                            unit_cost: 100)])
        }
        # rubocop:enable Layout/ArgumentAlignment
        let(:payment_reminder) { PaymentReminder.create(invoice: invoice, level: 1) }

        [:create].each do |action|
          it "can #{action} in #{layer.name}" do
            is_expected.to be_able_to(action, payment_reminder)
          end
        end
      end
    end
  end
end
