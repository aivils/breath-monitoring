class AddC19ProbabilityToMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :measurements, :c19_probability, :integer
  end
end
