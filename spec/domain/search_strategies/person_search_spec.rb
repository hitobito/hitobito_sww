# frozen_string_literal: true

#  Copyright (c) 2012-2024, Schweizer Alpen-Club. This file is part of
#  hitobito_sac_cas and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sac_cas.

require "spec_helper"

describe SearchStrategies::PersonSearch do
  describe "#search_fulltext" do
    let(:user) { people(:zuercher_wanderer) }

    before do
      user.update!(magazin_abo_number: 24052021)
    end

    it "finds accessible person by magazin_abo_number" do
      result = search_class(user.magazin_abo_number.to_s).search_fulltext

      expect(result).to include(user)
    end

    it "finds accessible person by manual_member_number" do
      result = search_class(user.manual_member_number.to_s).search_fulltext

      expect(result).to include(user)
    end

    it "finds accessible person by id" do
      result = search_class(user.id.to_s).search_fulltext

      expect(result).to include(user)
    end
  end

  def search_class(term = nil, page = nil)
    described_class.new(user, term, page)
  end
end