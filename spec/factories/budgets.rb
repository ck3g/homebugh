# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :budget do
    user
    category { create(:category, user: user) }
    currency
    limit { 100.99 }
  end
end
