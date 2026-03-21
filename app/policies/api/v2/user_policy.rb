module Api
  module V2
    class UserPolicy < ApplicationPolicy
      include PolicyHelper

      class Scope < Scope
        def resolve
          return scope.all if user.is_admin?

          scope.where(id: user.id)
        end
      end

      def update_profile?
        is_admin?
      end

      def profile?
        is_admin?
      end
    end
  end
end
