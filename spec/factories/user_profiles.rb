FactoryBot.define do
  factory :user_profile, class: 'User::Profile' do
    association :user
    display_time { 30 }
    record_mode { :default }
    voice_control { false }
    frames_per_second { :"15" }
    code { nil }
  end
end
