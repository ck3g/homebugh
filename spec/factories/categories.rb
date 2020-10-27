
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "category ##{n}" }
    category_type_id { CategoryType.spending }
    user

    factory :invalid_category do
      name { nil }
    end

    factory :spending_category do
      sequence(:name) { |n| "spending ##{n}" }
      category_type_id { CategoryType.spending }
    end

    factory :income_category do
      sequence(:name) { |n| "income ##{n}" }
      category_type_id { CategoryType.income }
    end
  end
end
