class AddSpiAsdiToMeasurements < ActiveRecord::Migration[7.0]
  def change
    add_column :measurements, :spi_score, :integer
    add_column :measurements, :asdi_score, :integer
  end
end
