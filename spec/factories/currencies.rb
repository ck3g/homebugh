# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :currency do
    sequence(:name) { |n| "Currency##{n}" }
    unit ""
  end
end
