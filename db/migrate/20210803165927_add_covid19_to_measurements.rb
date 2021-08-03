class AddCovid19ToMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :measurements, :c19_host, :boolean
  end
end
