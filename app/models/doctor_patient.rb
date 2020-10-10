class DoctorPatient < ApplicationRecord
  belongs_to :doctor, class_name: 'User', counter_cache: :patients_count
  belongs_to :patient, class_name: 'User', counter_cache: :doctors_count
end
