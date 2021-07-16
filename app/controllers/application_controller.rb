class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, except: :index, unless: :no_pundit_controller?
  after_action :verify_policy_scoped, only: :index, unless: :no_pundit_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def no_pundit_controller?
    is_a?(ActiveAdmin::BaseController) ||
      is_a?(DeviseController) ||
      is_a?(Api::V1::ApiController)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
