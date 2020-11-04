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
          f.has_many :profile, new_record: false do |pf|
            pf.input :id, as: :hidden
            pf.input :display_time, as: :select, collection: User::Profile::DISPLAY_TIMES
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
      row :display_time do |user|
        user.profile.display_time
      end
      row :roles
      row :patients
      row :doctors
    end
    active_admin_comments
  end

  permit_params :email, :password, :password_confirmation, role_ids: [],
    patient_ids: [], doctor_ids: [],
    profile_attributes: [
      :id,
      :display_time,
    ]
end
