module Sww::VariousAbility
  extend ActiveSupport::Concern

  LIMITED_ROLES_PARENTS = [
    Group::Mitglieder,
    Group::Kontakte
  ].freeze

  included do
    on(LabelFormat) do
      class_side(:index).everybody_unless_only_restricted_roles
    end
  end

  def everybody_unless_only_restricted_roles
    !user.roles.all? do |r|
      r.basic_permissions_only ||
        LIMITED_ROLES_PARENTS.include?(r.class.module_parent)
    end
  end
end
