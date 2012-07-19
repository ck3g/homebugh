
FactoryGirl.define do
  factory :transaction do
    summ 10.0
    comment "Comment"
    association :user
    association :category
    association :account

    factory :invalid_transaction do
      summ nil
    end
  end
end
