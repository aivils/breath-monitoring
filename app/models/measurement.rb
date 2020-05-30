class Measurement < ApplicationRecord
  belongs_to :user

  scope :approved, -> { where(approved: true) }
  scope :processed, -> { where(processed: true) }
end
