# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe Group::StatisticsController do
  let(:group) { groups(:berner_wanderwege) }
  let(:user) do
    Fabricate(Group::Geschaeftsstelle::Mitarbeiter.sti_name,
      group: groups(:berner_geschaeftsstelle)).person
  end

  before { sign_in(user) }

  describe "GET show" do
    context "event_participation statistic" do
      it "renders successfully with default date range" do
        get :show, params: {group_id: group.id, key: :event_participation}

        expect(response).to have_http_status(200)
        statistic = assigns(:statistic)
        expect(statistic.from_date).to eq(Time.zone.today.beginning_of_year)
        expect(statistic.to_date).to eq(Time.zone.today.end_of_year)
      end

      it "uses date params when provided" do
        get :show,
          params: {group_id: group.id, key: :event_participation, from: "01.03.2023",
                   to: "31.10.2023"}

        expect(response).to have_http_status(200)
        statistic = assigns(:statistic)
        expect(statistic.from_date).to eq(Date.new(2023, 3, 1))
        expect(statistic.to_date).to eq(Date.new(2023, 10, 31))
      end

      it "includes sublayers by default" do
        get :show, params: {group_id: group.id, key: :event_participation}

        expect(assigns(:statistic).include_sublayers?).to be true
      end

      it "excludes sublayers when param is false" do
        get :show,
          params: {group_id: group.id, key: :event_participation, include_sublayers: "false"}

        expect(assigns(:statistic).include_sublayers?).to be false
      end
    end

    context "people statistic" do
      it "renders successfully with default stichtag" do
        get :show, params: {group_id: group.id, key: :people}

        expect(response).to have_http_status(200)
        expect(assigns(:statistic).stichtag).to eq(Time.zone.today)
      end

      it "uses date param when provided" do
        get :show, params: {group_id: group.id, key: :people, date: "01.03.2023"}

        expect(response).to have_http_status(200)
        expect(assigns(:statistic).stichtag).to eq(Date.new(2023, 3, 1))
      end

      it "includes sublayers by default" do
        get :show, params: {group_id: group.id, key: :people}

        expect(assigns(:statistic).include_sublayers?).to be true
      end

      it "excludes sublayers when param is false" do
        get :show, params: {group_id: group.id, key: :people, include_sublayers: "false"}

        expect(assigns(:statistic).include_sublayers?).to be false
      end

      it "defaults selected_group to the given group" do
        get :show, params: {group_id: group.id, key: :people}

        expect(assigns(:statistic).selected_group).to eq(group)
      end

      context "with a selectable sub-layer" do
        let(:group) { groups(:schweizer_wanderwege) }
        let(:user) do
          Fabricate(Group::SchweizerWanderwege::Mitarbeitende.sti_name, group: group).person
        end

        it "uses selected_group_id param, without being shadowed by the group_id route param" do
          other_layer = groups(:zuercher_wanderwege)

          get :show,
            params: {group_id: group.id, key: :people, selected_group_id: other_layer.id}

          expect(assigns(:statistic).selected_group).to eq(other_layer)
        end
      end

      context "rendering" do
        render_views
        include Capybara::RSpecMatchers

        it "renders the group header and all statistic cards" do
          get :show, params: {group_id: group.id, key: :people}

          expect(response).to have_http_status(200)
          expect(response.body).to have_css(".card-header", text: group.to_s)
          expect(response.body).to have_css(".card-header", text: "Übersicht")
          expect(response.body).to have_css(".card-header", text: "Sprache")
          expect(response.body).to have_css(".card-header", text: "Geschlecht")
          expect(response.body).to have_css(".card-header", text: "Altersstruktur")
          expect(response.body).to have_css(".progress-bar")
        end
      end
    end
  end
end
