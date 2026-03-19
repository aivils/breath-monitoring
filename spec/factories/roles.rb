FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role-#{n}" }

    trait :admin do
      name { Role::ADMIN }
    end

    trait :therapist do
      name { Role::THERAPIST }
    end
  end
end
