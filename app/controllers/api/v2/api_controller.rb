module Api
  module V2
    class ApiController < ApplicationController
      respond_to :json

      skip_forgery_protection
      before_action :authenticate_api_v2_user!

      private

      def authenticate_api_v2_user!
        return if authenticate_with_jwt
        return if authenticate_with_apikey

        render json: { error: "This is not an authorized request." }, status: :unauthorized
      end

      def authenticate_with_jwt
        self.resource = warden.authenticate(scope: :user)
        @current_api_user = resource if resource.present?
      end

      def authenticate_with_apikey
        apikey = params[:apikey]
        @current_api_user = User.find_by(apikey: apikey) if apikey.present?
      end

      attr_accessor :resource

      def current_api_user
        @current_api_user
      end
      helper_method :current_api_user

      def pundit_user
        @current_api_user
      end
    end
  end
end
