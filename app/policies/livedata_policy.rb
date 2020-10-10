class LivedataPolicy < Struct.new(:user, :home)
  def show?
    user.roles.livedata.any?
  end
end
