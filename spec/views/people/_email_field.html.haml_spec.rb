#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe "people/_email_field.html.haml" do
  let(:person) { people(:berner_wanderer) }
  let(:form_builder) { StandardFormBuilder.new(:person, person, view, {}) }

  before do
    allow(view).to receive(:entry).and_return(person)
    allow(view).to receive(:can?).and_return(false)
    allow(controller).to receive(:permitted_attrs).and_return(permitted_attrs)
  end

  subject do
    render partial: "people/email_field", locals: {f: form_builder}
    Capybara::Node::Simple.new(@rendered)
  end

  context "when email is permitted and user can update email" do
    let(:permitted_attrs) { [:email] }

    before do
      allow(view).to receive(:can?).with(:update_email, person).and_return(true)
    end

    it "renders email as input field" do
      is_expected.to have_css("input[name='person[email]']")
    end
  end

  context "when email is permitted but user cannot update email" do
    let(:permitted_attrs) { [:email] }

    before do
      allow(view).to receive(:can?).with(:update_email, person).and_return(false)
    end

    it "renders email as plaintext" do
      is_expected.not_to have_css("input[name='person[email]']")
      is_expected.to have_css("p.form-control-plaintext", text: person.email)
    end
  end

  context "when email is restricted" do
    let(:permitted_attrs) { [:first_name, :last_name] }

    before do
      allow(view).to receive(:can?).with(:update_email, person).and_return(true)
    end

    it "renders email as plaintext even with update_email ability" do
      is_expected.not_to have_css("input[name='person[email]']")
      is_expected.to have_css("p.form-control-plaintext", text: person.email)
    end
  end
end
