class CreateUserProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false
      t.integer :display_time, default: 30

      t.timestamps
    end
  end
end
