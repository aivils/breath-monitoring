module Api
  module V2
    class ApiController < ApplicationController
      respond_to :json

      skip_forgery_protection
      before_action :authenticate_user

      private

      def authenticate_user
        apikey = params[:apikey]
        @current_api_user = User.find_by(apikey: apikey) if apikey.present?
        render json: {  error: "This is not a authorized request." },
                      status: :unauthorized unless @current_api_user
      end
    end
  end
end
