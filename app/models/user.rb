class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :measurements
  has_and_belongs_to_many :roles

  def is_admin?
    roles.admin.any?
  end

  protected

  def password_required?
    !persisted? || !password.blank? || !password_confirmation.blank?
  end
end
