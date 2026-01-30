# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe "people/_actions_show.html.haml" do
  before do
    allow(view).to receive(:can?).and_return(false)
    allow(view).to receive(:current_user).and_return(person)

    # Set proper controller context for translation lookup
    controller.class_eval do
      def controller_path = "people"

      def action_name = "show"
    end

    allow(view).to receive(:entry) { person.decorate }
    allow(view).to receive(:parent) { group }
    allow(view).to receive(:path_args) { [group, person] }
    assign(:group, group)

    # Stub out dropdown_people_export as not relevant for this test.
    allow(view).to receive(:dropdown_people_export).and_return("")
  end

  let(:person) { people(:berner_wanderer) }
  let(:group) { groups(:berner_mitglieder) }

  subject do
    render
    Capybara::Node::Simple.new(@rendered)
  end

  describe "split button" do
    context "when user can edit person" do
      before do
        allow(view).to receive(:can?).with(:edit, person.decorate).and_return(true)
      end

      it "is shown" do
        is_expected.to have_link("Aufteilen", href: new_group_person_split_path(group, person))
      end

      it "has scissors icon" do
        is_expected.to have_css("a[href='#{new_group_person_split_path(group,
          person)}'] i.fa-scissors")
      end
    end

    context "when user cannot edit person" do
      before do
        allow(view).to receive(:can?).with(:edit, person.decorate).and_return(false)
      end

      it "is not shown" do
        is_expected.not_to have_link("Aufteilen")
      end
    end
  end
end
