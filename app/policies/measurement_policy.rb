class MeasurementPolicy < ApplicationPolicy
  include PolicyHelper

  class Scope < Scope
    def resolve
      return scope.all if user.is_admin?

      if user.roles.doctor.exists?
        scope.where(user_id: [user.id] + user.patients.ids)
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def new?
    is_user?
  end

  def create?
    is_user?
  end

  def presence?
    is_user?
  end

  def update?
    show?
  end

  def show?
    visible?
  end

  def review?
    user.is_admin?
  end

  private

  def visible?
    return true if user.is_admin?
    return true if user.roles.doctor.exists? && (record.user_id == user.id || user.patients.exists?(id: record.user_id))

    record.user_id == user.id
  end
end
