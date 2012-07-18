
FactoryGirl.define do
  factory :category do
    name "Food"
    category_type_id CategoryType.spending
    association :user

    factory :invalid_category do
      name nil
    end
  end
end
