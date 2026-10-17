class AddVideoCaptureModeToUserProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :user_profiles, :video_capture_mode, :integer, default: 0, null: false
  end
end
