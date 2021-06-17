class AddDataWindowFieldsToMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :measurements, :data_window_start, :float
    add_column :measurements, :data_window_end, :float
  end
end
