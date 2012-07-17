
FactoryGirl.define do
  factory :account do
    name "Account"
    association :user

    factory :from_account do
      name "From Account"
      funds 100
    end

    factory :to_account do
      name "To Account"
    end
  end
end
