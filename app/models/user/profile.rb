class User::Profile < ApplicationRecord
  DISPLAY_TIMES = [30, 60, 120]
  RECORD_MODES = { default: 0, limited_120sec: 1 }
  belongs_to :user

  validates :code, format: { with: /\A[-a-z0-9]+\Z/i, message: :code_is_invalid }, allow_nil: true

  enum record_mode: RECORD_MODES
end
