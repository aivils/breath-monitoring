module PolicyHelper
  def is_user?
    !user.nil?
  end

  def is_admin?
    @is_admin ||= user&.is_admin?
  end
end

