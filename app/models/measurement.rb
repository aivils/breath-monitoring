class Measurement < ApplicationRecord
  include ActiveModel::Serializers::JSON

  belongs_to :user

  scope :approved, -> { where(approved: true) }
  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false).or(where(processed: nil)) }
  scope :api_measurements, -> (user) do
    if user.is_admin?
      all
    else
      joins(user: :doctor_patients)
        .where('measurements.user_id = doctor_patients.patient_id')
    end
  end

  def data_file=(tmp_file)
    tmp_file.rewind
    self.data = tmp_file.read
  end

  def to_front_end
    as_json(only: [
      :id,
      :created_at,
      :errors
    ])
  end
end
