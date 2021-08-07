class MeasurementsController < ApplicationController
  respond_to :json, :html

  def index
    @measurements = resource_scope.latest.page(params[:page]).per(10)
  end

  def new
    authorize(:measurement)
    @measurement = resource_scope.new
  end

  def create
    authorize(:measurement)
    @measurement = resource_scope.new(create_params)
    @measurement.save
    @measurement.update_column(:c19_host, true) if c19_host?
    render json: @measurement.to_front_end
  end

  def presence
    authorize(:measurement)
    @measurement = resource_scope.new
    current_user.update_column(:last_seen_at, DateTime.now)
    head :ok
  end

  def update
    authorize(:measurement)
    @measurement = resource_scope.find(params[:id])
    @measurement.update_attributes(update_params)
    render json: @measurement.to_front_end
  end

  private

  def create_params
    params.require(:measurement).permit(:data_file, :code)
  end

  def update_params
    params.require(:measurement).permit(:data_window_start, :data_window_end)
  end

  def resource_scope
    policy_scope(current_user.measurements)
  end
end
