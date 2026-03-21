class User::Profile < ApplicationRecord
  DISPLAY_TIMES = [30, 60, 120]
  RECORD_MODES = { default: 0, limited_120sec: 1 }
  FRAMES_PER_SECOND_MODES = {"15": 15, "30": 30, "60": 60}
  belongs_to :user
  has_one_attached :trend

  validates :code, format: { with: /\A[-a-z0-9]+\Z/i, message: :code_is_invalid }, allow_nil: true
  validate :trend_format

  enum record_mode: RECORD_MODES
  enum frames_per_second: FRAMES_PER_SECOND_MODES

  private

  def trend_format
    return unless trend.attached?
    return if trend.content_type.in?(%w[image/png image/jpeg image/jpg])

    errors.add(:trend, "must be a PNG or JPG")
  end
end
