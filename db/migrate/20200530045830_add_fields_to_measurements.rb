class AddFieldsToMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :measurements, :approved, :boolean
    add_index :measurements, :approved
    add_column :measurements, :processed, :boolean
    add_index :measurements, :processed
  end
end
