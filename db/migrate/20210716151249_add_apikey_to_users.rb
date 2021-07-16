class AddApikeyToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :apikey, :string
    add_index :users, :apikey
  end
end
