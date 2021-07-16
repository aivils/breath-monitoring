module Api
  module V1
    class MeasurementsController < ApiController
      respond_to :json

      def index
        respond_with(resource_scope.unprocessed)
      end

      def show
        respond_with(resource_scope.find(params[:id]))
      end

      def update
        measurement = resource_scope.find(params[:id])
        measurement.update_attributes(update_params)
        respond_with(measurement)
      end

      private

      def resource_scope
        Measurement.api_measurements(@current_api_user)
      end

      def update_params
        params.require(:measurement).permit(:processed, :c19_probability)
      end
    end
  end
end
