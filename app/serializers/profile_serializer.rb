class ProfileSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :user_id, :code, :display_time,
             :record_mode, :voice_control,
             :frames_per_second, :trend_url, :created_at, :updated_at

  def trend_url
    return unless object.trend.attached?

    rails_blob_url(object.trend, only_path: true)
  end
end
