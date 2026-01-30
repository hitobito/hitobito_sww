# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require "spec_helper"

describe People::SplitForm do
  let(:group) { groups(:berner_mitglieder) }
  let(:original_person) do
    Fabricate(:person,
      first_name: "Tom + Tina",
      last_name: "Tester",
      email: "tom.tina@example.com",
      gender: "m",
      birthday: Date.new(1980, 1, 1))
  end
  let(:split_form) { described_class.new(group: group, original_person: original_person) }

  def person_1 = split_form.person_1

  def person_2 = split_form.person_2

  def housemates(person) = Household.new(person).people - [person]

  describe "#initialize" do
    it "initializes with group and original_person" do
      expect(split_form.group).to eq(group)
      expect(split_form.original_person).to eq(original_person)
    end

    it "initializes person_1 clone from original_person with proposed first name" do
      allow_any_instance_of(described_class)
        .to receive(:proposed_first_names)
        .and_return(["Proposed 1", "Proposed 2"])

      expect(person_1).to be_a(Person)
      expect(person_1.first_name).to eq("Proposed 1")
      expect(person_1.last_name).to eq("Tester")
      expect(person_1.email).to eq("tom.tina@example.com")

      expect(person_1).to eq(split_form.original_person)
      expect(person_1.object_id).not_to eq(split_form.original_person.object_id)
    end

    it "initializes person_2 with proposed first name and original last name" do
      allow_any_instance_of(described_class)
        .to receive(:proposed_first_names)
        .and_return(["Proposed 1", "Proposed 2"])

      expect(person_2).to be_a(Person)
      expect(person_2.first_name).to eq("Proposed 2")
      expect(person_2.last_name).to eq("Tester")

      expect(person_2).not_to eq(split_form.original_person)
      expect(person_2).not_to eq(person_1)
    end

    it "initializes person_2_role with default Role in primary group of original person" do
      primary_group = groups(:zuercher_wanderwege)
      original_person.update!(primary_group: primary_group)
      expect(split_form.person_2_role).to be_a(Role)
      expect(split_form.person_2_role.group).to eq primary_group
      expect(split_form.person_2_role.person).to eq person_2
      expect(split_form.person_2_role.start_on).to eq Date.current
      expect(split_form.person_2_role.end_on).to be_nil
    end
  end

  describe "#proposed_first_names" do
    [" + ", "+ ", " +", " und ", " UND ", " et ", " u. ", " & "].each do |separator|
      it "splits first name with '#{separator}'" do
        original_person.first_name = "Tom#{separator}Tina"
        form = described_class.new(group: group, original_person: original_person)
        expect(form.proposed_first_names).to eq(["Tom", "Tina"])
      end
    end

    it "without separator in first name returns original  firstname and empty string" do
      original_person.first_name = "Tom"
      form = described_class.new(group: group, original_person: original_person)
      expect(form.proposed_first_names).to eq(["Tom", ""])
    end

    it "with nil first name returns empty strings" do
      original_person.first_name = nil
      form = described_class.new(group: group, original_person: original_person)
      expect(form.proposed_first_names).to eq(["", ""])
    end
  end

  describe "#person_1_attributes=" do
    let(:new_attributes) do
      {
        first_name: "Timmie",
        last_name: "Toaster",
        email: "timmie.toaster@example.com",
        gender: "m",
        birthday: Date.new(1979, 5, 15)
      }
    end

    it "assigns attributes to person_1" do
      split_form.person_1_attributes = new_attributes
      expect(person_1.first_name).to eq("Timmie")
      expect(person_1.last_name).to eq("Toaster")
      expect(person_1.email).to eq("timmie.toaster@example.com")
      expect(person_1.gender).to eq("m")
      expect(person_1.birthday).to eq(Date.new(1979, 5, 15))
    end

    context "when email is changed to blank and original had email" do
      it "creates an additional email with the original email" do
        split_form.person_1_attributes = new_attributes.merge(email: "")

        additional_emails = person_1.additional_emails
        expect(additional_emails.size).to eq(1)
        expect(additional_emails.first.email).to eq("tom.tina@example.com")
        expect(additional_emails.first.label).to eq(AdditionalEmail.predefined_labels.first)
      end
    end

    context "when email is present" do
      it "does not create additional email" do
        split_form.person_1_attributes = new_attributes
        expect(person_1.additional_emails).to be_empty
      end
    end

    context "when original email was blank" do
      it "does not create additional email" do
        original_person.email = nil
        form = described_class.new(group: group, original_person: original_person)
        form.person_1_attributes = new_attributes.merge(email: "")
        expect(form.person_1.additional_emails).to be_empty
      end
    end
  end

  describe "#person_2_attributes=" do
    let(:new_attributes) do
      {
        first_name: "Thea",
        last_name: "Tester",
        email: "thea.tester@example.com",
        gender: "w",
        birthday: Date.new(1982, 3, 20)
      }
    end

    it "assigns attributes to person_2" do
      split_form.person_2_attributes = new_attributes
      expect(person_2.first_name).to eq("Thea")
      expect(person_2.last_name).to eq("Tester")
      expect(person_2.email).to eq("thea.tester@example.com")
      expect(person_2.gender).to eq("w")
      expect(person_2.birthday).to eq(Date.new(1982, 3, 20))
    end

    context "when person_1 has email and person_2 email is blank" do
      it "creates an additional email for person_2 with person_1's email" do
        person_1.email = "tom.tina@example.com"
        split_form.person_2_attributes = new_attributes.merge(email: "")

        additional_emails = person_2.additional_emails
        expect(additional_emails.size).to eq(1)
        expect(additional_emails.first.email).to eq("tom.tina@example.com")
        expect(additional_emails.first.label).to eq(AdditionalEmail.predefined_labels.first)
      end
    end

    context "when person_2 has email" do
      it "does not create additional email" do
        split_form.person_2_attributes = new_attributes
        expect(person_2.additional_emails).to be_empty
      end
    end

    context "when person_1 email is blank" do
      it "does not create additional email for person_2" do
        person_1.email = nil
        split_form.person_2_attributes = new_attributes.merge(email: "")
        expect(person_2.additional_emails).to be_empty
      end
    end
  end

  describe "#person_2_role_attributes=" do
    it "creates a role of specified type" do
      split_form.person_2_role_attributes = {
        type: "Group::Mitglieder::Aktivmitglied",
        group_id: group.id,
        label: "Test Label",
        start_on: Date.current.yesterday,
        end_on: 1.year.from_now.to_date
      }

      expect(split_form.person_2_role).to be_a(Group::Mitglieder::Aktivmitglied)
      expect(split_form.person_2_role.group_id).to eq(group.id)
      expect(split_form.person_2_role.label).to eq("Test Label")
      expect(split_form.person_2_role.start_on).to eq(Date.current.yesterday)
      expect(split_form.person_2_role.end_on).to eq(1.year.from_now.to_date)
      expect(split_form.person_2_role.person).to eq(person_2)
    end

    it "defaults to baseclass Role when type is blank" do
      split_form.person_2_role_attributes = {
        type: "",
        group_id: group.id
      }

      expect(split_form.person_2_role).to be_a(Role)
    end

    it "defaults to baseclass Role when type is missing" do
      split_form.person_2_role_attributes = {
        group_id: group.id
      }

      expect(split_form.person_2_role).to be_a(Role)
    end
  end

  describe "#save" do
    before do
      split_form.person_1_attributes = {
        first_name: "Tom",
        last_name: "Tester",
        email: "tom.tester@example.com",
        gender: "m",
        birthday: Date.new(1980, 1, 1)
      }
      split_form.person_2_attributes = {
        first_name: "Tina",
        last_name: "Tester",
        email: "tina.tester@example.com",
        gender: "w",
        birthday: Date.new(1982, 3, 20)
      }
      split_form.person_2_role_attributes = {
        type: "Group::Mitglieder::Aktivmitglied",
        group_id: group.id
      }
    end

    context "on success" do
      it "saves both people and role" do
        expect { split_form.save }.to change { Person.count }.by(1)
        expect(person_1.reload.email).to eq("tom.tester@example.com")
        expect(person_2.reload.email).to eq("tina.tester@example.com")
        expect(person_2.roles).to eq [split_form.person_2_role]
      end

      context "household management" do
        it "adds both people to a household" do
          expect(housemates(person_1)).to be_empty
          expect(housemates(person_2)).to be_empty

          split_form.save

          expect(housemates(person_1)).to eq [person_2]
          expect(housemates(person_2)).to eq [person_1]
        end

        it "adds new person to same household when original person already has housemates" do
          original_housemate = people(:zuercher_wanderer)
          original_person.household.add(original_housemate).save!
          original_household_key = original_person.reload.household_key

          split_form.save
          expect(housemates(person_1.reload)).to match_array([original_housemate, person_2])
          expect(person_1.household_key).to eq original_household_key
        end
      end
    end

    context "on validation failure" do
      shared_examples "does not save any person or role" do
        it "does not save any person or role" do
          expect { split_form.save }
            .to not_change { Person.count }
            .and not_change { Role.count }
            .and not_change { person_1.reload.first_name }
        end

        it "returns false" do
          expect(split_form.save).to be false
        end
      end

      %w[person_1 person_2].each do |person|
        context "when #{person} is invalid" do
          include_examples "does not save any person or role" do
            before do
              split_form.person_1_attributes = {
                first_name: "new name"
              }
              allow(send(person)).to receive(:valid?).and_return(false)
            end
          end
        end
      end

      context "when person_2_role is invalid" do
        include_examples "does not save any person or role" do
          before do
            split_form.person_2_role_attributes = {
              type: "Group::Mitglieder::Aktivmitglied",
              group_id: nil
            }
          end
        end
      end
    end
  end

  describe "#valid?" do
    before do
      split_form.person_1_attributes = {
        first_name: "Tom",
        last_name: "Tester",
        email: "tom@example.com"
      }
      split_form.person_2_attributes = {
        first_name: "Tina",
        last_name: "Tester",
        email: "tina@example.com"
      }
      split_form.person_2_role_attributes = {
        type: "Group::Mitglieder::Aktivmitglied",
        group_id: group.id
      }
    end

    it "is valid with valid attributes" do
      expect(split_form).to be_valid
    end

    context "person_1 validations" do
      it "is invalid when person_1 is invalid" do
        person_1.email = "invalid-email"
        expect(split_form).not_to be_valid
      end

      it "adds errors with prefix 'Person 1'" do
        person_1.email = "invalid-email"
        split_form.valid?
        person_1_errors = split_form.errors.full_messages.any? { |msg|
          msg.start_with?("Person 1:")
        }
        expect(person_1_errors).to be true
      end
    end

    context "person_2 validations" do
      it "is invalid when person_2 is invalid" do
        person_2.email = "invalid-email"
        expect(split_form).not_to be_valid
      end

      it "adds errors with prefix 'Person 2'" do
        person_2.email = "invalid-email"
        split_form.valid?
        person_2_errors = split_form.errors.full_messages.any? { |msg|
          msg.start_with?("Person 2:")
        }
        expect(person_2_errors).to be true
      end
    end

    context "person_2_role validations" do
      it "is invalid when person_2_role is invalid" do
        split_form.person_2_role.group_id = nil
        expect(split_form).not_to be_valid
      end

      it "adds errors with prefix 'Person 2'" do
        split_form.person_2_role.group_id = nil
        split_form.valid?
        person_2_errors = split_form.errors.full_messages.any? { |msg|
          msg.start_with?("Person 2:")
        }
        expect(person_2_errors).to be true
      end
    end

    context "multiple validation errors" do
      it "collects all errors" do
        person_1.email = "invalid-email"
        person_2.email = "another-invalid-email"
        split_form.valid?

        expect(split_form.errors.count).to be >= 2
      end
    end
  end

  describe "#role_group_options" do
    before do
      Fabricate(Group::Mitglieder::Aktivmitglied.sti_name.to_sym,
        group:, person: original_person)
    end

    it "returns groups in the same layer as original person's roles" do
      options = split_form.role_group_options
      expect(options).to be_present

      expected_groups = Group.without_deleted.where(layer_group_id: group.layer_group_id)
      expect(options).to match_array(expected_groups)
    end

    it "excludes deleted groups" do
      deleted_group = groups(:berner_geschaeftsstelle)
      deleted_group.update(deleted_at: Time.current)

      expect(split_form.role_group_options).to_not include(deleted_group)
    end
  end

  it "#role_group returns the group of person_2_role" do
    group = groups(:zuercher_mitglieder)
    split_form.person_2_role.group = group
    expect(split_form.role_group).to eq(group)
  end
end
