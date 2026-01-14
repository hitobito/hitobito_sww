# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

Rails.application.load_tasks

describe "import:people_fo" do
  after do
    Rake::Task["import:people_fo"].reenable
  end

  context "valid people" do
    before do
      allow_any_instance_of(Pathname).to receive(:join)
        .and_return(Wagons.find("sww")
        .root
        .join("spec/fixtures/files/people_fo.csv"))
    end

    it "raises if given no argument" do
      expect do
        Rake::Task["import:people_fo"].invoke
      end.to raise_error(RuntimeError, "group id must be passed as first argument")
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
        expect do
          Rake::Task["import:people_fo"].invoke(groups(:berner_mitglieder).id)
        end.to change { Person.count }.by(5)
      end.to output("Successfully imported 5/5 rows\n").to_stdout

      person = Person.find_by(alabus_id: "1skuw-b52nqz-g2iw4kjn-2-g21sdwqh-qa7")
      expect(person).to be_present

      expect(person.country).to eq("DE")
      expect(person.title).to eq("Dr.")
      expect(person.gender).to eq("m")
      expect(person.magazin_abo_number).to eq(1000)
      expect(person.name_add_on).to eq("Mustermann")
      expect(person.email).to eq("max.muster@example.com")
      expect(person.roles.with_inactive.count).to eq(2)

      mitglied = person.roles.first
      magazin_abo = person.roles.with_inactive.last

      expect(mitglied.type).to eq(Group::Mitglieder::Aktivmitglied.sti_name)
      expect(mitglied.start_on).to eq(DateTime.new(1977, 1, 1))
      expect(mitglied.end_on).to be_nil

      expect(magazin_abo.type).to eq(Group::Mitglieder::MagazinAbonnent.sti_name)
      expect(magazin_abo.start_on).to eq(DateTime.new(1990, 10, 12))
      expect(magazin_abo.end_on).to eq(DateTime.new(2006, 2, 12))

      expect(person.taggings.count).to eq(3)

      person.taggings.each do |tagging|
        expect(["abo:kombi", "category:Einzelmitglied mit Magazin",
          "Newsletter"]).to include(tagging.tag.name)
      end

      expect(person.phone_numbers.count).to eq(2)

      mobile = person.phone_numbers.find_by(label: "Mobil")
      expect(mobile.number).to eq("+41 12 300 30 30")

      main = person.phone_numbers.find_by(label: "Privat")
      expect(main.number).to eq("+41 42 300 30 30")

      expect(person.social_accounts.first.name).to eq("https://www.hitobito.com")

      expect(person.notes.first.text).to eq("GV")

      company = Person.find_by(alabus_id: "haw31-axzcd1-jb44x23z-z-jtxn23wd1-k42")
      expect(company).to be_present
      expect(company.company_name).to eq("Hitobito AG")
      expect(company.manual_member_number).to eq(42)
    end

    it "imports mail as additional mail if already taken" do
      expect do
        Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)
      end.to output("Successfully imported 5/5 rows\n").to_stdout

      person = Person.find_by(alabus_id: "1s23w-b52n1x-2ciw2kjn-g-g213bwvh-1x7")
      expect(person).to be_present

      expect(person.email).to be_nil
      expect(person.additional_emails.count).to eq(1)
      expect(person.additional_emails.first.email).to eq("max.muster@example.com")
    end

    it "sets role start_on on a day before end_on if not set" do
      expect do
        Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)
      end.to output("Successfully imported 5/5 rows\n").to_stdout

      person = Person.find_by(alabus_id: "dcwe1-vbsdw2-2cib1kbs-p-g2bnbw1h-2sd")
      expect(person).to be_present

      expect(person.roles.active.count).to eq(0)
      expect(person.roles.with_inactive.count).to eq(2)

      mitglied = person.roles.with_inactive.first
      magazin_abo = person.roles.with_inactive.last

      expect(mitglied.type).to eq(Group::Mitglieder::Aktivmitglied.sti_name)
      expect(mitglied.start_on).to eq(DateTime.new(2002, 11, 29))
      expect(mitglied.end_on).to eq(DateTime.new(2002, 11, 30))

      expect(magazin_abo.type).to eq(Group::Mitglieder::MagazinAbonnent.sti_name)
      expect(magazin_abo.start_on).to eq(DateTime.new(1998, 12, 31))
      expect(magazin_abo.end_on).to eq(DateTime.new(1999, 1, 1))
    end

    it "imports role only if start_on can be set" do
      expect do
        Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)
      end.to output("Successfully imported 5/5 rows\n").to_stdout

      person_with_two_roles = Person.find_by(alabus_id: "1skuw-b52nqz-g2iw4kjn-2-g21sdwqh-qa7")
      person_with_one_role = Person.find_by(alabus_id: "1s23w-b52n1x-2ciw2kjn-g-g213bwvh-1x7")
      person_without_roles = Person.find_by(alabus_id: "bew31-axzcd1-jbhox23z-z-jtxn23wd1-k3g")

      expect(person_with_two_roles.roles.with_inactive.count).to eq(2)
      expect(person_with_one_role.roles.with_inactive.count).to eq(1)
      expect(person_without_roles.roles.with_inactive.count).to eq(0)
    end

    it "assigns Schweiz as fallback country" do
      expect do
        Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)
      end.to output("Successfully imported 5/5 rows\n").to_stdout

      person = Person.find_by(alabus_id: "bew31-axzcd1-jbhox23z-z-jtxn23wd1-k3g")
      expect(person).to be_present

      expect(person.country).to eq("CH")
    end
  end

  context "invalid people" do
    before do
      allow_any_instance_of(Pathname).to receive(:join)
        .and_return(Wagons.find("sww")
        .root
        .join("spec/fixtures/files/invalid_people_fo.csv"))
    end

    it "does not import person without alabus id and prints to stdout" do
      expected_output = ["Successfully imported 5/6 rows",
        "FAILED ROWS:",
        # rubocop:todo Layout/LineLength
        "first_name: Daniel, last_name: Failing, email: failing@example.com, alabus_id: \n",
        # rubocop:enable Layout/LineLength
        # rubocop:todo Layout/LineLength
        "nothing was imported due to errors. Please fix import source file and try again.\n"].join("\n")
      # rubocop:enable Layout/LineLength

      expect do
        Rake::Task["import:people_fo"].invoke(groups(:berner_wanderwege).id)
      end.to output(expected_output).to_stdout
    end
  end
end

describe "import:people_cms" do
  let!(:benutzerkonten_group) { groups(:benutzerkonten) }

  after do
    Rake::Task["import:people_cms"].reenable
  end

  context "valid people" do
    before do
      allow_any_instance_of(Pathname).to receive(:join)
        .and_return(Wagons.find("sww")
        .root
        .join("spec/fixtures/files/people_cms.csv"))
    end

    it "assigns Schweiz as fallback country" do
      expect do
        Rake::Task["import:people_cms"].invoke
      end.to output(/Successfully imported 2\/2 rows/).to_stdout

      person = Person.find_by(sww_cms_profile_id: 42)
      expect(person).to be_present

      expect(person.country).to eq("CH")
    end

    it "assigns Deutsch as fallback language" do
      expect do
        Rake::Task["import:people_cms"].invoke
      end.to output(/Successfully imported 2\/2 rows/).to_stdout

      person = Person.find_by(sww_cms_profile_id: 42)
      expect(person).to be_present

      expect(person.language).to eq("de")
    end
  end
end
