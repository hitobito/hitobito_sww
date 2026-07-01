require "spec_helper"

describe "mailing_lists/messages/_form.html.haml" do
  let(:letter) { Message::Letter.new }
  let(:mailing_list) { mailing_lists(:zuercher) }
  let(:group) { groups(:zuercher_wanderwege) }

  subject(:dom) { Capybara::Node::Simple.new(render) }

  before do
    allow(view).to receive(:entry).and_return(letter)
    allow(view).to receive(:parent).and_return(mailing_list)
    allow(view).to receive(:group_mailing_list_recipient_counts_path)
      .and_return(group_mailing_list_recipient_counts_path(group, mailing_list))
  end

  it "should have checkbox to include membership card" do
    expect(dom).to have_field("Mitgliederausweis mit drucken")
  end
end
