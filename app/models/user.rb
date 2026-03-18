class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :registerable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_many :measurements, dependent: :destroy
  has_and_belongs_to_many :roles
  has_many :doctor_patients, foreign_key: :doctor_id, dependent: :destroy
  has_many :patients, through: :doctor_patients
  has_many :patient_doctors, class_name: 'DoctorPatient', foreign_key: :patient_id, dependent: :destroy
  has_many :doctors, through: :patient_doctors
  has_one :profile

  after_create :make_profile
  accepts_nested_attributes_for :profile, allow_destroy: false

  scope :online, -> { where('last_seen_at > ?', 30.seconds.ago) }

  def is_admin?
    roles.admin.any?
  end


  protected

  def password_required?
    !persisted? || !password.blank? || !password_confirmation.blank?
  end

  private

  def make_profile
    !profile && create_profile!
  end

  class << self
    def ransackable_attributes(auth_object = nil)
      %w[
        id
        email
        created_at
        patients_count
      ]
    end

    def ransortable_attributes(auth_object = nil)
      ransackable_attributes(auth_object)
    end

    def ransackable_associations(auth_object = nil)
      %w[
        profile
        roles
        patients
        doctors
      ]
    end
  end
end
