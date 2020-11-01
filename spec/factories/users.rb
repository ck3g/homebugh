require 'factory_bot'

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { "password" }
    confirmed_at { DateTime.current }

    factory :user_example_com do
      email { 'user@example.com' }
    end

    trait :demo_user do
      demo_user { true }
    end
  end
end
