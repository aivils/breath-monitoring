class Measurement < ApplicationRecord
  include ActiveModel::Serializers::JSON

  belongs_to :user

  scope :approved, -> { where(approved: true) }
  scope :processed, -> { where(processed: true) }

  def data_file=(tmp_file)
    tmp_file.rewind
    self.data = tmp_file.read
  end

  def attributes
    {
      id: nil,
      created_at: nil,
      errors: nil
    }
  end
end
