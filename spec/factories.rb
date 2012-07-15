require 'factory_girl'

FactoryGirl.define do
  factory :user do
    email "user@test.com"
    password "password"
  end

  factory :account do
    name "Account"
    association :user, factory: :user
  end

  factory :from_account, class: Account do
    name "From Account"
    funds 100
    association :user, factory: :user
  end

  factory :to_account, class: Account do
    name "To Account"
    association :user, factory: :user
  end

  factory :cash_flow do
    amount 55
    association :from_account, factory: :from_account
    association :to_account, factory: :to_account
    association :user, factory: :user
  end

  factory :spending_category, class: Category do
    name "Category"
    association :user, factory: :user
    category_type_id CategoryType.spending
  end
end
