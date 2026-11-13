# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"
require_relative "../../db/migrate/20261104124655_move_address_care_of_to_address_addition"

RSpec.describe MoveAddressCareOfToAddressAddition, type: :migration do
  subject(:migration) { described_class.new }

  around do |example|
    ActiveRecord::Migration.verbose = false
    example.run
    ActiveRecord::Migration.verbose = true
  end

  def person_with(address_care_of:, address_addition: nil)
    Fabricate(:person).tap { |person| person.update_columns(address_care_of:, address_addition:) }
  end

  describe "#up" do
    [
      "c/o Meier", "C/O Meier", "c / o Meier", "C/0 Meier", "c.o. Meier", "℅ Meier", "p.A. Meier",
      "bei Meier", "chez Dupont", "presso Rossi", "z.Hd. Meier", "zHd Meier", "z.H Meier",
      "z. H. Meier", "zuhanden Meier", "zu Handen Meier", "Attn: Meier", "Att. Pres. Rossi",
      "à l'attention de M. Dupont", "À l'attention de Mme Dupont", "A l'att. de M. Dupont",
      "A l'att.de M. Dupont", "all'attenzione di Rossi", "  c/o Meier"
    ].each do |value|
      it "keeps #{value.inspect} as c/o address" do
        person = person_with(address_care_of: value)

        migration.up

        expect(person.reload).to have_attributes(address_care_of: value, address_addition: nil)
      end
    end

    [
      "Hinterhaus", "3. Stock", "Postfach 12", "Zentralstrasse 44", "beim Bahnhof",
      "Atelier de Sion", "Avenue de la Gare 12", "Alleeweg 28", "Zhang Wei", "Wohnung 3, c/o Meier",
      "Herr Meier", "Frau Meier", "Monsieur Dupont", "Madame Dupont", "Mme Dupont", "Sig. Rossi",
      "Familie Meier", "Famille Dupont"
    ].each do |value|
      it "moves #{value.inspect} to address addition" do
        person = person_with(address_care_of: value)

        migration.up

        expect(person.reload).to have_attributes(address_care_of: nil, address_addition: value)
      end
    end

    [nil, "", "   "].each do |value|
      it "leaves #{value.inspect} unchanged" do
        person = person_with(address_care_of: value)

        migration.up

        expect(person.reload).to have_attributes(address_care_of: value, address_addition: nil)
      end
    end

    it "moves values of groups, additional addresses and event guests" do
      records = [groups(:berner_wanderwege), Fabricate(:additional_address),
        Fabricate(:event_guest)]
      records.each { |record| record.update_columns(address_care_of: "Hinterhaus") }

      migration.up

      records.each do |record|
        expect(record.reload).to have_attributes(address_care_of: nil,
          address_addition: "Hinterhaus")
      end
    end

    it "does not change invoices" do
      invoice = invoices(:invoice)
      invoice.update_columns(recipient_address_care_of: "Hinterhaus")

      migration.up

      expect(invoice.reload).to have_attributes(recipient_address_care_of: "Hinterhaus",
        recipient_address_addition: nil)
    end
  end

  describe "#down" do
    it "moves address addition back if there is no c/o address" do
      person = person_with(address_care_of: nil, address_addition: "Hinterhaus")

      migration.down

      expect(person.reload).to have_attributes(address_care_of: "Hinterhaus", address_addition: nil)
    end

    it "keeps address addition if there is a c/o address" do
      person = person_with(address_care_of: "c/o Meier", address_addition: "Hinterhaus")

      migration.down

      expect(person.reload).to have_attributes(address_care_of: "c/o Meier",
        address_addition: "Hinterhaus")
    end
  end
end
