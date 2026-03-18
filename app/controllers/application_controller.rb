class ApplicationController < ActionController::Base
  include Pundit::Authorization
  after_action :verify_pundit_authorization, unless: :no_pundit_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  def no_pundit_controller?
    is_a?(ActiveAdmin::BaseController) ||
      devise_controller? ||
      is_a?(Api::V1::ApiController) ||
      is_a?(Api::V2::ApiController)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def c19_host?
    @c19_host ||= request.env['SERVER_NAME'].present? && request.env['SERVER_NAME'].match(/covid19|anshealth/)
  end

  helper_method :c19_host?
end
