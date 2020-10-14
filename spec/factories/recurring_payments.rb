# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :recurring_payment do
    title "Rent"
    user
    category { create(:category, user: user) }
    account { create(:account, user: user) }
    amount 503
    frequency_amount 1
    frequency 2
    next_payment_on { 1.month.from_now.to_date }
  end
end
