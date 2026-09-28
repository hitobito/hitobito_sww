# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

class Group::Mitglieder < ::Group
  children Group::Mitglieder

  mounted_attr :droptours_export, :boolean

  validate :droptours_upload_config_present, if: :droptours_export

  ### ROLES

  class Aktivmitglied < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Freimitglied < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Organisationen < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Partner < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Spender < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class MagazinAbonnent < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  roles Aktivmitglied, Passivmitglied, Freimitglied, Organisationen,
    Partner, Spender, MagazinAbonnent

  private

  def droptours_upload_config_present
    return if Export::DroptoursUploadConfig.instance.config
      .key?(droptours_fachorganisation&.id)

    errors.add(:droptours_export, :upload_config_missing,
      fachorganisation: droptours_fachorganisation&.name)
  end

  # The layer_group_id of new records is only assigned after save, so the
  # fachorganisation is derived from the parent in that case.
  def droptours_fachorganisation
    layer_group || parent&.layer_group
  end
end
