ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    #column :current_sign_in_at
    #column :sign_in_count
    column :roles
    column :created_at
    actions
  end

  filter :email
  #filter :current_sign_in_at
  #filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :roles, as: :check_boxes
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :roles
    end
    active_admin_comments
  end

  permit_params :email, :password, :password_confirmation, role_ids: []
end
