#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

require "spec_helper"

describe "event/participation_contact_datas/_name_fields.html.haml" do
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
    render partial: "event/participation_contact_datas/name_fields", locals: {f: form_builder}
    Capybara::Node::Simple.new(@rendered)
  end

  context "when attributes are permitted" do
    let(:permitted_attrs) { [:first_name, :last_name, :nickname] }

    it "renders first_name as input field" do
      is_expected.to have_css("input[name='entry[first_name]']")
    end

    it "renders last_name as input field" do
      is_expected.to have_css("input[name='entry[last_name]']")
    end
  end

  context "when attributes are not permitted" do
    let(:permitted_attrs) { [:others] }

    it "renders first_name as plaintext" do
      is_expected.to have_css("p.form-control-plaintext", text: person.first_name)
      is_expected.not_to have_css("input[name='entry[first_name]']")
    end

    it "renders last_name as plaintext" do
      is_expected.to have_css("p.form-control-plaintext", text: person.last_name)
      is_expected.not_to have_css("input[name='entry[last_name]']")
    end
  end

end
