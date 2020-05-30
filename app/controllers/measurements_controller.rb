class MeasurementsController < ApplicationController
  def create
    @measurement = resource_scope.new(create_params)
    authorize(@measurement)
    @measurement.save
  end

  private

  def create_params
    params.require(:measurement).permit(:data_file)
  end

  def resource_scope
    policy_scope(current_user.measurements)
  end
end
