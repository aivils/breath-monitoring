class ProfileSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :code, :display_time,
             :record_mode, :voice_control,
             :frames_per_second, :created_at, :updated_at
end
