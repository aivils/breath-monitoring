class HomeController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    authorize :home
    @users_present = User.online
  end
end
