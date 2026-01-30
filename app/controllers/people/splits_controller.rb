# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module People
  class SplitsController < ApplicationController
    before_action :authorize_action, :role
    helper_method :entry, :original_person, :group

    delegate :original_person, to: :entry

    def new
      @all_roles = person.roles.with_inactive
    end

    def create
      assign_attributes

      if @split.save
        redirect_to group_person_path(group, person), notice: t(".success")
      else
        render :new, status: 422
      end
    end

    def role_types
      assign_attributes
    end

    private

    def split
      @split ||= People::SplitForm.new(group:, original_person: person)
    end

    def person
      @person ||= Person.find(params.require(:person_id))
    end

    def group
      @group ||= Group.find(params.require(:group_id))
    end

    def role
      @role = entry.person_2_role
    end

    def entry = split

    def assign_attributes = entry.assign_attributes(split_form_params)

    def authorize_action = authorize!(:update, person)

    def split_form_params
      params.require(:people_split_form).permit(
        person_1_attributes: [:first_name, :last_name, :email, :gender, :birthday],
        person_2_attributes: [:first_name, :last_name, :email, :gender, :birthday],
        person_2_role_attributes: [:group_id, :label, :start_on, :end_on, :type]
      )
    end
  end
end
