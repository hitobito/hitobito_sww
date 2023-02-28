class AddSpecificAuthorToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :specific_author, :string
  end
end
