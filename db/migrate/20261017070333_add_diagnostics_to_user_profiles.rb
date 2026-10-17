class AddDiagnosticsToUserProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :user_profiles, :diagnostics, :boolean, default: false, null: false
  end
end
