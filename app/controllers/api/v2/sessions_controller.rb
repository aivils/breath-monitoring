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
    end
  end
end
