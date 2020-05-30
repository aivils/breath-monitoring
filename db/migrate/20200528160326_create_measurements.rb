class CreateMeasurements < ActiveRecord::Migration[6.0]
  def change
    create_table :measurements do |t|
      t.references :user, null: false, foreign_key: true
      t.text :data

      t.timestamps
    end
  end
end
