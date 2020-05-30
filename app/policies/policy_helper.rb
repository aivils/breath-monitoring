module PolicyHelper
  def is_user?
    !user.nil?
  end

  def is_admin?
    user&.admin?
  end
end

