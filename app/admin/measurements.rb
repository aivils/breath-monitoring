ActiveAdmin.register Measurement do
  scope :all
  scope :approved
  scope :processed
  scope :c19_host

  index do
    selectable_column
    id_column
    column :user
    column :code
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
  filter :c19_host
  filter :created_at

  show do
    attributes_table do
      row :id
      row :user
      row :code
      row :c19_host
      row :approved
      row :processed
      row :c19_probability
      row :data_window_start
      row :data_window_end
      row :graph do |record|
        render 'admin/measurements/graph', { measurement: record }
      end
      row :data do |record|
        record.data.gsub("\n", '</br>').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters

  permit_params :user_id, :data, :approved, :processed, :data_window_start, :data_window_end, :c19_host
end
