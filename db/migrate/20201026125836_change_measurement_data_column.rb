class ChangeMeasurementDataColumn < ActiveRecord::Migration[6.0]
  def change
    change_column :measurements, :data, :mediumtext
  end
end
