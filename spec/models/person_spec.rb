# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe Person do
  it "includes custom attributes" do
    %I[magazin_abo_number].each do |a|
      expect(Person::PUBLIC_ATTRS).to include(a)
    end

    %I[member_number alabus_id].each do |a|
      expect(Person::INTERNAL_ATTRS).to include(a)
    end
  end

  describe "#sww_salutation" do
    let(:person) { people(:berner_wanderer) }

    context "with person language de" do
      before { person.update(language: :de) }

      context "with gender other" do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq "Andere" }
        it { expect(person.sww_salutation(skip_other: true)).to be_nil }
      end

      context "with gender f" do
        before { person.update(gender: "w") }

        it { expect(person.sww_salutation).to eq "Frau" }
      end

      context "with gender m" do
        before { person.update(gender: "m") }

        it { expect(person.sww_salutation).to eq "Herr" }
      end
    end

    context "with person language fr" do
      before { person.update(language: :fr) }

      context "with gender other" do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq "Autre" }
        it { expect(person.sww_salutation(skip_other: true)).to be_nil }
      end

      context "with gender f" do
        before { person.update(gender: "w") }

        it { expect(person.sww_salutation).to eq "Madame" }
      end

      context "with gender m" do
        before { person.update(gender: "m") }

        it { expect(person.sww_salutation).to eq "Monsieur" }
      end
    end

    context "with person language it" do
      before { person.update(language: :it) }

      context "with gender other" do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq "Altro" }
        it { expect(person.sww_salutation(skip_other: true)).to be_nil }
      end

      context "with gender f" do
        before { person.update(gender: "w") }

        it { expect(person.sww_salutation).to eq "Signora" }
      end

      context "with gender m" do
        before { person.update(gender: "m") }

        it { expect(person.sww_salutation).to eq "Signor" }
      end
    end

    context "with person language en" do
      before { person.update(language: :en) }

      context "with gender other" do
        before { person.update(gender: nil) }

        it { expect(person.sww_salutation).to eq "Andere" }
      end

      context "with gender f" do
        before { person.update(gender: "w") }

        it { expect(person.sww_salutation).to eq "Frau" }
      end

      context "with gender m" do
        before { person.update(gender: "m") }

        it { expect(person.sww_salutation).to eq "Herr" }
      end
    end

    # not possible on person due to presence validation but possible for event
    # guests that also have this method and do not require language
    context "with blank person language" do
      before do
        person.update!(gender: "m")
        allow(person).to receive(:language).and_return ""
      end

      it "returns salutation in default locale" do
        expect(person.sww_salutation).to eq "Herr"
      end
    end
  end
end
