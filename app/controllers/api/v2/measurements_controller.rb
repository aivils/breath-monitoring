module Api
  module V2
    class MeasurementsController < ApiController
      respond_to :json
      PER_PAGE = 20

      def index
        q = resource_scope.ransack(params[:q])
        q.sorts = 'created_at desc' if q.sorts.empty?
        result = q.result.page(params[:page]).per(params[:per_page] || PER_PAGE)
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
        measurement = resource_scope.find(params[:id])
        authorize measurement

        respond_with(measurement.as_json(methods: :data_parsed))
      end

      def update
        measurement = resource_scope.find(params[:id])
        authorize measurement

        measurement.update(client_update_params)
        respond_with(measurement)
      end

      def review
        measurement = resource_scope.find(params[:id])
        authorize measurement

        measurement.update(admin_update_params)
        respond_with(measurement)
      end

      def create
        measurement = @current_api_user.measurements.new(create_params)
        authorize measurement

        measurement.save
        measurement.update_column(:c19_host, true) if c19_host?
        respond_with(measurement)
      end

      private

      def resource_scope
        policy_scope(Measurement)
      end

      def create_params
        params.require(:measurement).permit(:data_file, :code)
      end

      def client_update_params
        params.require(:measurement).permit(:data_window_start, :data_window_end)
      end

      def admin_update_params
        params.require(:measurement).permit(:processed, :c19_probability, :spi_score, :asdi_score)
      end
    end
  end
end
