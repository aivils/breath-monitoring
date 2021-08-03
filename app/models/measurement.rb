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
  scope :c19_host, -> { where(c19_host: true) }

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

  def data_parsed
    data.split("\n")
    .map { |item| item.split(" ") }
    .map do |item|
      item[1] = 0 if item[1] == 'NaN'
      item[0] = item[0].to_f
      item[1] = item[1].to_f
      item
    end
  end
end
