
FactoryBot.define do
  factory :transaction do
    summ { 10.0 }
    comment { "Comment" }
    user
    category
    account

    factory :invalid_transaction do
      summ { "" }
    end
  end
end
