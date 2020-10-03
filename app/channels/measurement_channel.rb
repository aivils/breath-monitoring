class MeasurementChannel < ApplicationCable::Channel
  def receive(data)
    user = User.find(data["user_id"])
    MeasurementChannel.broadcast_to(user, data)
  end

  def subscribed
    user = User.find(params[:user_id])
    stream_for user
  end

  def unsubscribed
  end
end
