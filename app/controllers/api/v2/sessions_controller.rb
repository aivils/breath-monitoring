module Api
  module V2
    class SessionsController < Devise::SessionsController
      respond_to :json
      skip_forgery_protection

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

      def respond_to_on_destroy
        if current_user
          render json: { message: 'Logged out successfully.' }, status: :ok
        else
          render json: { message: 'No active session.' }, status: :unauthorized
        end
      end
    end
  end
end
