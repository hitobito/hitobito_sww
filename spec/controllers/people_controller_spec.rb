require "spec_helper"

describe PeopleController do
  let(:person) { people(:berner_wanderer) }
  let(:group) { groups(:berner_mitglieder) }

  describe "PUT #update" do
    context "editing own profile" do
      before { sign_in(person) }

      context "restricted attributes" do
        %w[first_name last_name].each do |attr|
          it "does not allow updating #{attr}" do
            expect do
              put :update, params: {group_id: group.id, id: person.id,
                                    person: {attr => "Changed"}}
            end.not_to change { person.reload.send(attr) }
          end
        end

        it "does not allow updating email" do
          expect do
            put :update, params: {group_id: group.id, id: person.id,
                                  person: {email: "changed@example.com"}}
          end.not_to change { person.reload.email }
        end
      end

      it "still updates unrestricted attributes" do
        expect do
          put :update, params: {group_id: group.id, id: person.id,
                                person: {nickname: "Wandervogel"}}
        end.to change { person.reload.nickname }.to("Wandervogel")
      end
    end

    context "editing another person" do
      let(:other_person) { people(:berner_wanderer) }
      let(:admin) do
        Fabricate(Group::Geschaeftsstelle::Mitarbeiter.sti_name,
          group: groups(:berner_geschaeftsstelle)).person
      end

      before { sign_in(admin) }

      context "restricted attributes" do
        %w[first_name last_name].each do |attr|
          it "allows updating #{attr}" do
            expect do
              put :update, params: {group_id: group.id, id: other_person.id,
                                    person: {attr => "Changed"}}
            end.to change { other_person.reload.send(attr) }.to("Changed")
          end
        end

        it "allows updating email" do
          expect do
            put :update, params: {group_id: group.id, id: other_person.id,
                                  person: {email: "changed@example.com"}}
          end.to change { other_person.reload.email }.to("changed@example.com")
        end
      end
    end
  end
end
