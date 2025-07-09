# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require "spec_helper"

describe SearchStrategies::PersonSearch do
  describe "#search_fulltext" do
    let(:user) { people(:zuercher_wanderer) }

    before do
      user.update!(magazin_abo_number: 24052021)
    end

    it "finds accessible person by magazin_abo_number" do
      result = search_class(people(:zuercher_wanderer).magazin_abo_number.to_s).search_fulltext

      expect(result).to include(people(:zuercher_wanderer))
    end

    it "finds accessible person by manual_member_number" do
      result = search_class(people(:zuercher_wanderer).manual_member_number.to_s).search_fulltext

      expect(result).to include(people(:zuercher_wanderer))
    end
  end

  def search_class(term = nil, page = nil)
    described_class.new(user, term, page)
  end
end