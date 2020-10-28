class Users::ProfilesController < ApplicationController
  skip_after_action :verify_policy_scoped, only: [ :show, :update ]
  before_action :set_profile
  respond_to :json, :html

  def show
    authorize(@profile)
  end

  def update
    authorize(@profile)
    @profile.update_attributes(update_params)
    respond_with(@profile, location: profile_path)
  end

  private

  def update_params
    params.require(:profile).permit(:code)
  end

  def set_profile
    @profile = current_user.profile
  end
end
