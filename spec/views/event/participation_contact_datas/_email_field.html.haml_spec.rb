#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe "event/participation_contact_datas/_email_field.html.haml" do
  let(:person) { people(:berner_wanderer) }
  let(:event) { Fabricate(:event, groups: [groups(:berner_wanderwege)]) }
  let(:entry) { Event::ParticipationContactData.new(event, person, {}) }
  let(:form_builder) { StandardFormBuilder.new(:entry, entry, view, {}) }

  before do
    allow(view).to receive(:entry).and_return(entry)
    allow(view).to receive(:event).and_return(event)
    allow(controller).to receive(:permitted_attrs).and_return(permitted_attrs)
  end

  subject do
    render partial: "event/participation_contact_datas/email_field", locals: {f: form_builder}
    Capybara::Node::Simple.new(@rendered)
  end

  context "when email is permitted" do
    let(:permitted_attrs) { [:email] }

    it "renders email as input field" do
      is_expected.to have_css("input[name='entry[email]']")
    end
  end

  context "when email is restricted" do
    let(:permitted_attrs) { [:first_name] }

    it "renders email as plaintext" do
      is_expected.not_to have_css("input[name='entry[email]']")
      is_expected.to have_css("p.form-control-plaintext", text: person.email)
    end
  end

end
