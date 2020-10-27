# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :recurring_payment do
    title { "Rent" }
    user
    category { create(:category, user: user) }
    account { create(:account, user: user) }
    amount { 503 }
    frequency_amount { 1 }
    frequency { 2 }
    next_payment_on { 1.month.from_now.to_date }

    trait :monthly do
      frequency_amount { 1 }
      frequency { 2 }
    end

    trait :due do
      next_payment_on { 1.day.ago.to_date }
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
