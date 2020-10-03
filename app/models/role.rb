class Role < ApplicationRecord
  ROLES = [
    ADMIN = 'Admin'.freeze,
    DOCTOR = 'Doctor'.freeze
  ].freeze

  has_and_belongs_to_many :users

  scope :admin, -> { where(name: ADMIN) }
end
