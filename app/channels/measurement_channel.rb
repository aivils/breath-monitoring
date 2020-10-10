class MeasurementChannel < ApplicationCable::Channel
  def receive(data)
    user = User.find(data["id"])
    MeasurementChannel.broadcast_to(user, data)
  end

  def subscribed
    user = User.find(params[:id])
    stream_for user
  end

  def unsubscribed
  end
end
