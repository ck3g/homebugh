
FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account ##{n}" }
    user
    currency

    factory :from_account do
      sequence(:name) { |n| "From Account ##{n}" }
      funds 100
    end

    factory :to_account do
      sequence(:name) { |n| "To Account ##{n}" }
    end

    factory :invalid_account do
      name nil
    end

    trait :deleted do
      status 'deleted'
    end

    trait :hidden do
      show_in_summary false
    end
  end
end
