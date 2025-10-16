# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Person::Address do
  let(:attrs) {
    {
      first_name: "Jane",
      last_name: "Doe",
      nickname: nil,
      address_care_of: "Office",
      street: "Lagistrasse",
      housenumber: "12a",
      postbox: "Postfach 10",
      zip_code: 1080,
      town: "Jamestown"
    }
  }
  let(:person) { Fabricate.build(:person, attrs) }

  subject(:text) { described_class.new(person).for_pdf_label(person.to_s) }

  describe "gender" do
    it "renders without gender if unknown" do
      expect(text).to start_with "Jane Doe"
    end

    [
      ["de", %w[Herr Frau]],
      ["fr", %w[Monsieur Madame]],
      ["it", %w[Signor Signora]]
    ].each do |locale, (male, female)|
      it "uses #{male} for male in #{locale}" do
        person.language = locale
        person.gender = :m

        expect(text).to start_with male
      end

      it "uses #{female} for male in #{locale}" do
        person.language = locale
        person.gender = :w

        expect(text).to start_with female
      end
    end
  end

  describe "person" do
    it "renders full address" do
      person.gender = :w

      expect(text).to eq <<~TEXT
        Frau
        Jane Doe
        Office
        Lagistrasse 12a
        Postfach 10
        1080 Jamestown
      TEXT
    end
  end

  describe "company" do
    it "prints company and person name" do
      person.company = true
      person.company_name = "Company LTD"
      expect(text).to eq <<~TEXT
        Company LTD
        Jane Doe
        Office
        Lagistrasse 12a
        Postfach 10
        1080 Jamestown
      TEXT
    end

    it "ignores gender inferred salutation when printing company name" do
      person.gender = :w
      person.company = true
      person.company_name = "Company LTD"
      expect(text).to_not include "Frau"
    end

    it "prints name only once if they are identical" do
      person.company = true
      person.company_name = "Jane Doe"
      expect(text).to eq <<~TEXT
        Jane Doe
        Office
        Lagistrasse 12a
        Postfach 10
        1080 Jamestown
      TEXT
    end

    it "prints name only once if they are identical" do
      person.company = true
      person.company_name = "Jane Doe"
      expect(text).to eq <<~TEXT
        Jane Doe
        Office
        Lagistrasse 12a
        Postfach 10
        1080 Jamestown
      TEXT
    end

    it "prints gender inferred salutation if company and names are identical" do
      person.company = true
      person.company_name = "Jane Doe"
      person.gender = :w
      expect(text).to start_with "Frau"
    end
  end
end
