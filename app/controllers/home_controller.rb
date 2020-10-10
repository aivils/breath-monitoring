class HomeController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    authorize :home
    @users_present = policy_scope(User.online, policy_scope_class: LivedataPolicy::Scope)
  end
end
