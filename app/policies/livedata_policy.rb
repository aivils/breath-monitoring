class LivedataPolicy < Struct.new(:user, :home)
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.is_admin?
        scope.all
      else
        scope.where(id: user.patient_ids)
      end
    end

    private

    attr_reader :user, :scope
  end

  def show?
    user && user.roles.livedata.any?
  end
end
