class Role < ApplicationRecord
  ROLES = [
    ADMIN = 'Admin'.freeze,
    THERAPIST = 'Therapist'.freeze
  ].freeze

  has_and_belongs_to_many :users

  scope :admin, -> { where(name: ADMIN) }
  scope :doctor, -> { where(name: THERAPIST) }
  scope :livedata, -> { where(name: [ADMIN, THERAPIST]) }
end
