require 'factory_girl'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "password"
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
