
FactoryGirl.define do
  factory :category do
    name "Food"
    category_type_id CategoryType.spending
    association :user

    factory :invalid_category do
      name nil
    end

    factory :spending_category do
      name "Category"
      category_type_id CategoryType.spending
    end
  end
end
