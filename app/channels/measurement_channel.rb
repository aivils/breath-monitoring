class MeasurementChannel < ApplicationCable::Channel
  def receive(data)
    ActionCable.server.broadcast("measurement_channel_1", data)
  end

  def subscribed
    stream_from "measurement_channel_1"
  end

  def unsubscribed
  end
end
