# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

seeder = GroupSeeder.new

root = Group.roots.first
srand(42)

if root.address.blank?
  root.update(seeder.group_attributes)
  root.default_children.each do |child_class|
    child_class.first.update(seeder.group_attributes)
  end
end

Group::Benutzerkonten.seed(:name, :parent_id,
                          {
                            name: 'CMS',
                            parent_id: root.id
                          })

fachorganisationen = Group::Fachorganisation.seed(:name, :parent_id,
                                                  {
                                                    name: 'Berner Wanderwege BWW',
                                                    parent_id: root.id
                                                  },
                                                  {
                                                    name: 'Zürcher Wanderwege',
                                                    parent_id: root.id
                                                  }
                                                 )

Group::GremiumProjektgruppe.seed(:name, :parent_id,
                                 {
                                   name: 'Gremium',
                                   parent_id: fachorganisationen[0].id
                                 },
                                 {
                                   name: 'Projektgruppe',
                                   parent_id: fachorganisationen[0].id
                                 },
                                 {
                                   name: 'Gremium',
                                   parent_id: fachorganisationen[1].id
                                 },
                                 {
                                   name: 'Projektgruppe',
                                   parent_id: fachorganisationen[1].id
                                 }
                                )

Group::Mitglieder.seed(:name, :parent_id,
                       {
                         name: 'Mitglieder',
                         parent_id: fachorganisationen[0].id
                       },
                       {
                         name: 'Mitglieder',
                         parent_id: fachorganisationen[1].id
                       }
                      )

Group.rebuild!
