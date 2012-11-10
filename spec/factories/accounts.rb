
FactoryGirl.define do
  factory :account do
    sequence(:name) { |n| "Account ##{n}" }
    association :user

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
  end
end
