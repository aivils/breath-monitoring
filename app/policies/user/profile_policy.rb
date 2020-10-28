class User::ProfilePolicy < ApplicationPolicy
  include PolicyHelper

  def show?
    is_user? && record.user = user
  end

  def update?
    is_user? && record.user = user
  end
end
