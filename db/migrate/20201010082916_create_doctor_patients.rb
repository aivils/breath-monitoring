class CreateDoctorPatients < ActiveRecord::Migration[6.0]
  def change
    create_table :doctor_patients do |t|
      t.references :doctor, null: false
      t.references :patient, null: false

      t.timestamps
    end
  end
end
