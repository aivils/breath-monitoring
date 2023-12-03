class AddVoiceControlToUserProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :user_profiles, :voice_control, :boolean, default: false
  end
end
