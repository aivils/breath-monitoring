ActiveAdmin.register Measurement do
  scope :all
  scope :approved
  scope :processed

  index do
    selectable_column
    id_column
    column :user
    column :approved
    column :processed
    column :created_at
    actions
  end

  filter :user, collection: -> {
    User.all.map { |user| [user.email, user.id] }
  }
  filter :approved
  filter :processed
  filter :created_at

  show do
    attributes_table do
      row :id
      row :user
      row :approved
      row :processed
      row :data do |record|
        record.data.gsub("\n", '</br>').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters

  permit_params :user_id, :data, :approved, :processed
end
