module Api
  module V1
    class MeasurementsController < ApiController
      respond_to :json
      PER_PAGE = 20

      def index
        respond_with(resource_scope.unprocessed.page(params[:page]).per(PER_PAGE).as_json(methods: :data_parsed))
      end

      def show
        respond_with(resource_scope.find(params[:id]).as_json(methods: :data_parsed))
      end

      def update
        measurement = resource_scope.find(params[:id])
        measurement.update_attributes(update_params)
        respond_with(measurement)
      end

      private

      def resource_scope
        scope = Measurement.api_measurements(@current_api_user)
        scope = scope.c19_host if c19_host?
        scope
      end

      def update_params
        params.require(:measurement).permit(:processed, :c19_probability)
      end
    end
  end
end
