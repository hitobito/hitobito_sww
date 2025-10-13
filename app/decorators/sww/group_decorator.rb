module Sww::GroupDecorator
  def allowed_roles_for_self_registration
    super - [Group::Benutzerkonten::StagingUser]
  end
end
