# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurring_payment do
    title "Rent"
    user
    category { create(:category, user: user) }
    account { create(:account, user: user) }
    amount 503
    frequency_amount 1
    frequency 2
  end
end
