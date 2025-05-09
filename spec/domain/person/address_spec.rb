# frozen_string_literal: true

#  Copyright (c) 2012-2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Person::Address do
  let(:attrs) { {first_name: "Jane", last_name: "Doe", nickname: nil, street: "Lagistrasse", housenumber: "12a", zip_code: 1080, town: "Jamestown"} }
  let(:person) { Fabricate.build(:person, attrs) }
  subject(:text) { described_class.new(person).for_pdf_label(person.to_s) }

  it "renders without gender if unknown" do
    expect(text).to eq <<~TEXT
    Jane Doe
    Lagistrasse 12a
    1080 Jamestown
    TEXT
  end

  [
    ["de", %w(Herr Frau)],
    ["fr", %w(Monsieur Madame)],
    ["it", %w(Signor Signora)],
  ].each do |locale, (male, female)|
    it "uses #{male} for male in #{locale}" do
      person.language = locale
      person.gender = :m

      expect(text).to eq <<~TEXT
      #{male}
      Jane Doe
      Lagistrasse 12a
      1080 Jamestown
      TEXT
    end

    it "uses #{female} for male in #{locale}" do
      person.language = locale
      person.gender = :w

      expect(text).to eq <<~TEXT
      #{female}
      Jane Doe
      Lagistrasse 12a
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
      Lagistrasse 12a
      1080 Jamestown
      TEXT
    end

    it "ignores gender inferred salutation when printing company name" do
      person.gender = :w
      person.company = true
      person.company_name = "Company LTD"
      expect(text).to eq <<~TEXT
      Company LTD
      Jane Doe
      Lagistrasse 12a
      1080 Jamestown
      TEXT
    end

    it "prints name only once if they are identical" do
      person.company = true
      person.company_name = "Jane Doe"
      expect(text).to eq <<~TEXT
      Jane Doe
      Lagistrasse 12a
      1080 Jamestown
      TEXT
    end

    it "prints name only once if they are identical" do
      person.company = true
      person.company_name = "Jane Doe"
      expect(text).to eq <<~TEXT
      Jane Doe
      Lagistrasse 12a
      1080 Jamestown
      TEXT
    end

    it "prints gender inferred salutation if company and names are identical" do
      person.company = true
      person.company_name = "Jane Doe"
      person.gender = :w
      expect(text).to eq <<~TEXT
      Frau
      Jane Doe
      Lagistrasse 12a
      1080 Jamestown
      TEXT
    end
  end
end
