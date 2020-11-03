class AddCodeToMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :measurements, :code, :string
  end
end
