module Api
  module V2
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json
        skip_forgery_protection

        def destroy
          signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))

          if signed_out
            render json: { message: 'Logged out successfully.' }, status: :ok
          else
            render json: { message: 'No active session.' }, status: :unauthorized
          end
        end

        private

        def respond_with(resource, _opts = {})
          render json: {
            message: 'Logged in successfully.',
            user: {
              id: resource.id,
              email: resource.email
            }
          }, status: :ok
        end

        def devise_mapping
          @devise_mapping ||= Devise.mappings[:user]
        end
      end
    end
  end
end
