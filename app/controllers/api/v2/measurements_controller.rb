module Api
  module V2
    class MeasurementsController < ApiController
      respond_to :json
      PER_PAGE = 20

      def index
        result = resource_scope.unprocessed.page(params[:page]).per(PER_PAGE)
        data = result.as_json(methods: :data_parsed)
        meta = {
          limit_value: result.limit_value,
          total_pages: result.total_pages,
          current_page: result.current_page,
          next_page: result.next_page,
        }
        respond_with(data: data, meta: meta)
      end

      def show
        respond_with(resource_scope.find(params[:id]).as_json(methods: :data_parsed))
      end

      def update
        measurement = resource_scope.find(params[:id])
        measurement.update(update_params)
        respond_with(measurement)
      end

      private

      def resource_scope
        scope = Measurement.api_measurements(@current_api_user).oldest
        scope = scope.c19_host if c19_host?
        scope
      end

      def update_params
        params.require(:measurement).permit(:processed, :c19_probability)
      end
    end
  end
end
