class MeasurementPolicy < ApplicationPolicy
  include PolicyHelper

  Scope = Struct.new(:user, :scope) do
    include PolicyHelper

    def resolve
      scope
    end
  end

  def new?
    is_user?
  end

  def create?
    is_user?
  end
end
