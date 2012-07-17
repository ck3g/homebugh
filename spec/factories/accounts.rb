
FactoryGirl.define do
  factory :account do
    name "Account"
    association :user
  end

  factory :from_account, class: Account do
    name "From Account"
    funds 100
    association :user
  end

  factory :to_account, class: Account do
    name "To Account"
    association :user
  end

end
