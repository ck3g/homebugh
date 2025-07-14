FactoryBot.define do
  factory :recurring_cash_flow do
    association :user
    association :from_account, factory: :account
    association :to_account, factory: :account
    amount { 100.00 }
    frequency { :monthly }
    frequency_amount { 1 }
    next_transfer_on { Date.current }

    trait :daily do
      frequency { :daily }
    end

    trait :weekly do
      frequency { :weekly }
    end

    trait :monthly do
      frequency { :monthly }
    end

    trait :yearly do
      frequency { :yearly }
    end

    trait :due do
      next_transfer_on { Date.current }
    end
  end
end
