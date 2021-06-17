class AddRecordModeToUserProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :user_profiles, :record_mode, :integer, default: 0
  end
end
