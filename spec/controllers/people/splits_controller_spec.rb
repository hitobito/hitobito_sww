# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe People::SplitsController do
  let(:group) { groups(:berner_wanderwege) }
  let(:person) { people(:berner_wanderer) }
  let(:user_with_permission) do
    Fabricate(Group::Geschaeftsstelle::Mitarbeiter.sti_name,
      group: groups(:berner_geschaeftsstelle)).person
  end
  let(:user_without_permission) { people(:zuercher_wanderer) }

  before { sign_in(user) }

  describe "GET #new" do
    context "as unauthorized user" do
      let(:user) { user_without_permission }

      it "raises CanCan::AccessDenied" do
        expect do
          get :new, params: {group_id: group.id, person_id: person.id}
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    context "as authorized user" do
      let(:user) { user_with_permission }

      it "renders new template" do
        get :new, params: {group_id: group.id, person_id: person.id}
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end

      it "assigns all_roles" do
        get :new, params: {group_id: group.id, person_id: person.id}
        expect(assigns(:all_roles)).to eq(person.roles.with_inactive)
      end

      it "assigns split form instance variables" do
        get :new, params: {group_id: group.id, person_id: person.id}
        expect(assigns(:split)).to be_a(People::SplitForm)
        expect(assigns(:split).original_person).to eq(person)
        expect(assigns(:split).group).to eq(group)
      end
    end
  end

  describe "POST #create" do
    let(:user) { person }
    let(:param) do
      {
        group_id: group.id,
        person_id: person.id,
        people_split_form: {
          person_1_attributes: {first_name: "Tom"}
        }
      }
    end

    context "as unauthorized user" do
      let(:user) { user_without_permission }

      it "raises CanCan::AccessDenied" do
        expect do
          post :create, params: param
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    context "as authorized user" do
      let(:user) { user_with_permission }

      it "when valid saves the split and redirects to person page with success notice" do
        expect_any_instance_of(People::SplitForm).to receive(:save).and_return(true)
        post :create, params: param
        expect(response).to redirect_to(group_person_path(group, person))
        expect(flash[:notice]).to be_present
      end

      it "when invalid renders new template with unprocessable entity status" do
        expect_any_instance_of(People::SplitForm).to receive(:save).and_return(false)
        post :create, params: param
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #role_types JS" do
    let(:user) { person }
    let(:params) do
      {
        group_id: group.id,
        person_id: person.id,
        people_split_form: {
          person_2_role_attributes: {
            type: "Group::GremiumProjektgruppe::Leitung",
            group_id: groups(:berner_gremium).id
          }
        }
      }
    end

    context "as unauthorized user" do
      let(:user) { user_without_permission }

      it "raises CanCan::AccessDenied" do
        expect do
          post :role_types, xhr: true, params: params, format: :js
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    context "as authorized user" do
      it "assigns attributes to the split form" do
        post :role_types, xhr: true, params: params, format: :js

        split = assigns(:split)
        expect(split).to be_a(People::SplitForm)
        expect(split.person_2_role.type).to eq("Group::GremiumProjektgruppe::Leitung")
        expect(split.person_2_role.group_id).to eq(groups(:berner_gremium).id)
      end

      it "renders successfully" do
        post :role_types, xhr: true, params: params, format: :js
        expect(response).to be_successful
      end
    end
  end
end
