class AddCounterCachesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :doctors_count, :integer, default: 0
    add_column :users, :patients_count, :integer, default: 0
  end
end
