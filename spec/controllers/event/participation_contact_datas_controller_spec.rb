require "spec_helper"

describe Event::ParticipationContactDatasController do
  let(:person) { people(:berner_wanderer) }
  let(:group) { groups(:berner_wanderwege) }
  let(:event) { Fabricate(:event, groups: [group]) }

  describe "PATCH #update" do
    let(:base_params) do
      {
        group_id: group.id,
        event_id: event.id,
        event_role: {type: "Event::Role::Participant"}
      }
    end

    context "editing own contact data" do
      before { sign_in(person) }

      context "restricted attributes" do
        %w[first_name last_name].each do |attr|
          it "does not update #{attr}" do
            expect do
              patch :update, params: base_params.merge(
                event_participation_contact_data: {
                  :first_name => person.first_name,
                  :last_name => person.last_name,
                  :email => person.email,
                  attr => "Changed"
                }
              )
            end.not_to change { person.reload.send(attr) }
          end
        end

        it "does not update email" do
          expect do
            patch :update, params: base_params.merge(
              event_participation_contact_data: {
                first_name: person.first_name,
                last_name: person.last_name,
                email: "changed@example.com"
              }
            )
          end.not_to change { person.reload.email }
        end
      end

      it "still updates unrestricted attributes" do
        expect do
          patch :update, params: base_params.merge(
            event_participation_contact_data: {
              first_name: person.first_name,
              last_name: person.last_name,
              email: person.email,
              nickname: "Wandervogel"
            }
          )
        end.to change { person.reload.nickname }.to("Wandervogel")
      end
    end
  end
end
