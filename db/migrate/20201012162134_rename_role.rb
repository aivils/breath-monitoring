class RenameRole < ActiveRecord::Migration[6.0]
  def up
    Role.find_by(name: 'Doctor')&.update_column(:name, 'Therapist')
  end

  def down
    Role.find_by(name: 'Therapist')&.update_column(:name, 'Doctor')
  end
end
