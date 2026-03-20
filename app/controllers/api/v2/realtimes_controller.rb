module Api
  module V2
    class RealtimesController < ApiController
      def show
        render json: {
          cable_url: cable_url,
          identifier: {
            channel: "MeasurementChannel",
            id: current_api_user.id
          }
        }
      end

      private

      def cable_url
        uri = URI.parse(request.base_url)
        uri.scheme = uri.scheme == "https" ? "wss" : "ws"
        "#{uri}/cable"
      end
    end
  end
end
