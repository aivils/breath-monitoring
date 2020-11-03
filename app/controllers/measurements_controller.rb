class MeasurementsController < ApplicationController
  before_action :ensure_user_profile_code, only: :new
  respond_to :json, :html

  def new
    authorize(:measurement)
    @measurement = resource_scope.new
  end

  def create
    authorize(:measurement)
    @measurement = resource_scope.new(create_params)
    @measurement.save
    respond_with(@measurement)
  end

  def presence
    authorize(:measurement)
    @measurement = resource_scope.new
    current_user.update_column(:last_seen_at, DateTime.now)
    head :ok
  end

  private

  def create_params
    params.require(:measurement).permit(:data_file, :code)
  end

  def resource_scope
    policy_scope(current_user.measurements)
  end

  def ensure_user_profile_code
    if current_user.profile.code.blank?
      redirect_to profile_path, alert: "To start the measurement you need to fill in the code in your profile."
    end
    true
  end
end
