module Api
  module V2
    module Users
      class PasswordsController < Devise::PasswordsController
        respond_to :json
        skip_forgery_protection

        def create
          render json: {
            error: 'Password reset is not available.'
          }, status: :not_implemented
        end

        private

        def devise_mapping
          @devise_mapping ||= Devise.mappings[:user]
        end
      end
    end
  end
end
