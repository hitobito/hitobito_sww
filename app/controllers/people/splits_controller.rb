# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module People
  class SplitsController < ApplicationController
    before_action :authorize_action, :entry

    helper_method :entry, :person, :group

    def new
    end

    def create
      binding.pry
    end

    private

    def split
      @split = People::SplitForm.new(group:, original_person: person)
    end

    def entry
      @entry ||= split
    end

    def person
      @person ||= Person.find(params.require(:person_id))
    end

    def group
      @group ||= Group.find(params.require(:group_id))
    end

    def authorize_action
      authorize!(:update, person)
    end
  end
end
