class User::Profile < ApplicationRecord
  DISPLAY_TIMES = [30, 60, 120]
  belongs_to :user
end
