class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, except: :index, unless: :no_pundit_controller?
  after_action :verify_policy_scoped, only: :index, unless: :no_pundit_controller?

  def no_pundit_controller?
    is_a?(ActiveAdmin::BaseController) ||
      is_a?(DeviseController)
  end
end
