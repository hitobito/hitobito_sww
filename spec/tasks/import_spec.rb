require 'spec_helper'

Rails.application.load_tasks

describe "import:people_fo" do
  before do
    expect_any_instance_of(Pathname).to receive(:join)
                                    .and_return(Wagons.find('sww')
                                                      .root
                                                      .join('spec/fixtures/files/people_fo.csv'))
  end

  after do
    Rake::Task["import:people_fo"].reenable
  end

  it "raises if given no argument" do
    expect do
      Rake::Task["import:people_fo"].invoke
    end.to raise_error(RuntimeError, 'group id must be passed as first argument')
  end

  it "raises if group with given id does not exist" do
    expect do
      Rake::Task["import:people_fo"].invoke(Group.maximum(:id).succ)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "raises if group with given id does not exist" do
    expect do
      Rake::Task["import:people_fo"].invoke(Group.maximum(:id).succ)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "imports people and companies from csv" do
    expect do
      Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)
    end.to change { Person.count }.by(5)

    person = Person.find_by(alabus_id: '1skuw-b52nqz-g2iw4kjn-2-g21sdwqh-qa7')
    expect(person).to be_present

    expect(person.country).to eq('DE')
    expect(person.title).to eq('Dr.')
    expect(person.gender).to eq('m')
    expect(person.magazin_abo_number).to eq(1000)
    expect(person.name_add_on).to eq('Mustermann')
    expect(person.email).to eq('max.muster@example.com')
    expect(person.roles.with_deleted.count).to eq(2)

    mitglied = person.roles.first
    magazin_abo = person.roles.with_deleted.last

    expect(mitglied.type).to eq(Group::Mitglieder::Aktivmitglied.sti_name)
    expect(mitglied.created_at).to eq(DateTime.new(1977, 1, 1))
    expect(mitglied.deleted_at).to be_nil

    expect(magazin_abo.type).to eq(Group::Mitglieder::MagazinAbonnent.sti_name)
    expect(magazin_abo.created_at).to eq(DateTime.new(1990, 10, 12))
    expect(magazin_abo.deleted_at).to eq(DateTime.new(2006, 2, 12))

    expect(person.taggings.count).to eq(3)

    person.taggings.each do |tagging|
      expect(['abo:kombi', 'category:Einzel', 'Newsletter']).to include(tagging.tag.name)
    end

    expect(person.phone_numbers.count).to eq(2)

    mobile = person.phone_numbers.find_by(label: 'Mobil')
    expect(mobile.number).to eq('+41 12 300 30 30')

    main = person.phone_numbers.find_by(label: 'Privat')
    expect(main.number).to eq('+41 42 300 30 30')

    expect(person.social_accounts.first.name).to eq('https://www.hitobito.com')

    expect(person.notes.first.text).to eq('GV')

    company = Person.find_by(alabus_id: 'haw31-axzcd1-jb44x23z-z-jtxn23wd1-k42')
    expect(company).to be_present
    expect(company.company_name).to eq('Hitobito AG')
    expect(company.member_number).to eq(42)
  end

  it "imports mail as additional mail if already taken" do
    Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)

    person = Person.find_by(alabus_id: '1s23w-b52n1x-2ciw2kjn-g-g213bwvh-1x7')
    expect(person).to be_present

    expect(person.email).to be_nil
    expect(person.additional_emails.count).to eq(1)
    expect(person.additional_emails.first.email).to eq('max.muster@example.com')
  end

  it "sets role created_at on a day before deleted_at if not set" do
    Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)

    person = Person.find_by(alabus_id: 'dcwe1-vbsdw2-2cib1kbs-p-g2bnbw1h-2sd')
    expect(person).to be_present

    expect(person.roles.without_deleted.count).to eq(0)
    expect(person.roles.with_deleted.count).to eq(2)

    mitglied = person.roles.with_deleted.first
    magazin_abo = person.roles.with_deleted.last

    expect(mitglied.type).to eq(Group::Mitglieder::Aktivmitglied.sti_name)
    expect(mitglied.created_at).to eq(DateTime.new(2002, 11, 29))
    expect(mitglied.deleted_at).to eq(DateTime.new(2002, 11, 30))

    expect(magazin_abo.type).to eq(Group::Mitglieder::MagazinAbonnent.sti_name)
    expect(magazin_abo.created_at).to eq(DateTime.new(1998, 12, 31))
    expect(magazin_abo.deleted_at).to eq(DateTime.new(1999, 1, 1))
  end

  it "imports role only if created_at can be set" do
    Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)

    person_with_two_roles = Person.find_by(alabus_id: '1skuw-b52nqz-g2iw4kjn-2-g21sdwqh-qa7')
    person_with_one_role = Person.find_by(alabus_id: '1s23w-b52n1x-2ciw2kjn-g-g213bwvh-1x7')
    person_without_roles = Person.find_by(alabus_id: 'bew31-axzcd1-jbhox23z-z-jtxn23wd1-k3g')

    expect(person_with_two_roles.roles.with_deleted.count).to eq(2)
    expect(person_with_one_role.roles.with_deleted.count).to eq(1)
    expect(person_without_roles.roles.with_deleted.count).to eq(0)
  end

  it "assigns Schweiz as fallback country" do
    Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)

    person = Person.find_by(alabus_id: 'bew31-axzcd1-jbhox23z-z-jtxn23wd1-k3g')
    expect(person).to be_present

    expect(person.country).to eq('CH')
  end
end

describe 'import:invoices_fo' do
  before do
    expect_any_instance_of(Pathname).to receive(:join)
                                    .and_return(Wagons.find('sww')
                                                      .root
                                                      .join('spec/fixtures/files/invoices_fo.csv'))

    groups(:berner_wanderwege).create_invoice_config!
  end

  after do
    Rake::Task["import:invoices_fo"].reenable
  end

  it "raises if given no argument" do
    expect do
      Rake::Task["import:invoices_fo"].invoke
    end.to raise_error(RuntimeError, 'group id must be passed as first argument')
  end

  it "raises if group with given id does not exist" do
    expect do
      Rake::Task["import:invoices_fo"].invoke(Group.maximum(:id).succ)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "raises if group with given id does not exist" do
    expect do
      Rake::Task["import:invoices_fo"].invoke(Group.maximum(:id).succ)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "imports invoices from csv" do
    recipient = Person.create!(alabus_id: '5c2o3xc-twcwrv-js1wkcxh-h-jsax76d7-bew1', first_name: 'Max')

    expect do
      Rake::Task["import:invoices_fo"].invoke(groups(:berner_wanderwege).id)
    end.to change { Invoice.count }.by(1)

    expect(Invoice.where(recipient: recipient).count).to eq(1)

    invoice = Invoice.find_by(recipient: recipient)

    expect(invoice.title).to eq('Rechnung Alabus Privatperson')
    expect(invoice.state).to eq('issued')
    expect(invoice.esr_number).to eq('00 37592 44815 05725 00000 00013')
    expect(invoice.sent_at).to eq(DateTime.new(2022, 3, 28))
    expect(invoice.created_at).to eq(DateTime.new(2022, 3, 28))

    expect(invoice.invoice_items.count).to eq(1)

    invoice_item = invoice.invoice_items.first

    expect(invoice_item.name).to eq('Privatperson')
    expect(invoice_item.unit_cost).to eq(75)
    expect(invoice_item.count).to eq(1)
  end

  it "does not import if recipient is not found" do
    expect do
      Rake::Task["import:invoices_fo"].invoke(groups(:berner_wanderwege).id)
    end.to change { Invoice.count }.by(0)
  end

  it "does not import invoices with other state than 'Offen'" do
    recipient_for_open_invoice = Person.create!(alabus_id: '5c2o3xc-twcwrv-js1wkcxh-h-jsax76d7-bew1', first_name: 'Max')
    recipient_for_non_open_invoice = Person.create!(alabus_id: 'wi2bn3f-tfbw3v-js1swvzh-h-jx75x634-beje', first_name: 'Alice')

    expect do
      Rake::Task["import:invoices_fo"].invoke(groups(:berner_wanderwege).id)
    end.to change { Invoice.count }.by(1)

    expect(Invoice.where(recipient: recipient_for_open_invoice).count).to eq(1)
    expect(Invoice.where(recipient: recipient_for_non_open_invoice).count).to eq(0)
  end

  it "assigns 0 as fallback unit_cost" do
    recipient = Person.create!(alabus_id: 'wi2bhef-tfcdxv-vcewwcvh-h-jx23x667-ghee', first_name: 'Bob')

    expect do
      Rake::Task["import:invoices_fo"].invoke(groups(:berner_wanderwege).id)
    end.to change { Invoice.count }.by(1)

    expect(Invoice.where(recipient: recipient).count).to eq(1)

    invoice = Invoice.find_by(recipient: recipient)
    expect(invoice.invoice_items.count).to eq(1)

    invoice_item = invoice.invoice_items.first

    expect(invoice_item.name).to eq('Familienmitglied')
    expect(invoice_item.unit_cost).to eq(0)
  end
end