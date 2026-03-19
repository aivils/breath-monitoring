FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
    apikey { SecureRandom.hex(16) }

    trait :admin do
      after(:create) do |user|
        user.roles << Role.find_or_create_by!(name: Role::ADMIN)
      end
    end

    trait :therapist do
      after(:create) do |user|
        user.roles << Role.find_or_create_by!(name: Role::THERAPIST)
      end
    end
  end
end
