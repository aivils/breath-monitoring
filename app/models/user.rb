class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :measurements
  has_and_belongs_to_many :roles
  has_many :doctor_patients, foreign_key: :doctor_id
  has_many :patients, through: :doctor_patients
  has_many :patient_doctors, class_name: 'DoctorPatient', foreign_key: :patient_id
  has_many :doctors, through: :patient_doctors

  scope :online, -> { where('last_seen_at > ?', 30.seconds.ago) }

  def is_admin?
    roles.admin.any?
  end

  protected

  def password_required?
    !persisted? || !password.blank? || !password_confirmation.blank?
  end
end
