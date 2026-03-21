ActiveAdmin.register User do
  index do
    selectable_column
    id_column
    column :email
    #column :current_sign_in_at
    #column :sign_in_count
    column :roles
    column :patients_count
    column :created_at
    actions
  end

  filter :email
  #filter :current_sign_in_at
  #filter :sign_in_count
  filter :created_at

  form do |f|
    f.semantic_errors
    tabs do
      tab 'Basic' do
        f.inputs 'Basic Details' do
          f.input :email
          f.input :password
          f.input :password_confirmation
          f.input :apikey
          f.has_many :profile, new_record: false do |pf|
            pf.input :id, as: :hidden
            pf.input :display_time, as: :select, collection: User::Profile::DISPLAY_TIMES, include_blank: false
            pf.input :record_mode,
              as: :select,
              collection: User::Profile.record_modes.keys.map { |k| [k.humanize, k] },
              include_blank: false
            pf.input :voice_control
            pf.input :frames_per_second,
              as: :select,
              collection: User::Profile.frames_per_seconds.keys.map { |k| [k.to_s.humanize, k] },
              include_blank: false
            pf.input :trend, as: :file
          end
        end
      end

      tab 'Relations' do
        f.inputs 'Relations' do
          f.input :roles, as: :check_boxes
          f.input :patients, as: :check_boxes, collection: User.where.not(id: f.object.id).pluck(:email, :id)
          f.input :doctors, as: :check_boxes, collection: User.where.not(id: f.object.id).pluck(:email, :id)
        end
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :apikey
      row :display_time do |user|
        user.profile.display_time
      end
      row :record_mode do |user|
        user.profile.record_mode
      end
      row :voice_control do |user|
        user.profile.voice_control
      end
      row :frames_per_second do |user|
        user.profile.frames_per_second
      end
      row :trend do |user|
        if user.profile.trend.attached?
          link_to url_for(user.profile.trend), target: "_blank", title: "Open full image" do
            image_tag user.profile.trend.variant(resize_to_limit: [200, 200])
          end
        else
          status_tag 'no image'
        end
      end
      row :roles
      row :patients
      row :doctors
    end
    active_admin_comments
  end

  permit_params :email, :password, :password_confirmation, :apikey, role_ids: [],
    patient_ids: [], doctor_ids: [],
    profile_attributes: [
      :id,
      :display_time,
      :record_mode,
      :voice_control,
      :frames_per_second,
      :trend,
    ]
end
