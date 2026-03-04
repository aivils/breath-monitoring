class AddFpsToUserProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :user_profiles, :frames_per_second, :integer, default: 15
  end
end
