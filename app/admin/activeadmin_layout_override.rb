module AdminLayoutOverride
  def build_active_admin_head
    within super do
      render "admin/layouts/custom_head"
    end
  end
end

ActiveAdmin::Views::Pages::Base.send :prepend, AdminLayoutOverride
