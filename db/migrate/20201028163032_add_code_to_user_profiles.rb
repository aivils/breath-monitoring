class AddCodeToUserProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :user_profiles, :code, :string
  end
end
