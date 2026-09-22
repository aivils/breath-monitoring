class PwaController < ApplicationController
  skip_forgery_protection
  skip_after_action :verify_pundit_authorization, only: [ :manifest, :service_worker ]

  def manifest
    render formats: :json, content_type: "application/manifest+json"
  end

  def service_worker
    render formats: :js, content_type: "text/javascript"
  end
end
