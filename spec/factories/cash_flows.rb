
FactoryBot.define do
  factory :cash_flow do
    amount 55
    association :user
    association :from_account
    association :to_account

    factory :invalid_cash_flow do
      from_account_id nil
    end
  end
end
