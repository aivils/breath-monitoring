class MeasurementsController < ApplicationController
  def new
    @measurement = resource_scope.new
    authorize(@measurement)
  end

  def create
    @measurement = resource_scope.new(create_params)
    authorize(@measurement)
    @measurement.save
  end

  def presence
    @measurement = resource_scope.new
    authorize(@measurement)
    current_user.update_column(:last_seen_at, DateTime.now)
    head :ok
  end

  private

  def create_params
    params.require(:measurement).permit(:data_file)
  end

  def resource_scope
    policy_scope(current_user.measurements)
  end
end
