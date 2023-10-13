
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "category ##{n}" }
    category_type factory: :category_type_expense
    user

    factory :invalid_category do
      name { nil }
    end

    factory :spending_category do
      sequence(:name) { |n| "spending ##{n}" }
      category_type factory: :category_type_expense
    end

    factory :income_category do
      sequence(:name) { |n| "income ##{n}" }
      category_type factory: :category_type_income
    end
  end

  factory :category_type do
    id { CategoryType.income }
    name { "income" }

    # From https://dev.to/jooeycheng/factorybot-findorcreateby-3h8k
    to_create do |instance|
      instance.attributes = CategoryType.find_or_create_by(id: instance.id).attributes
      instance.instance_variable_set('@new_record', false)
    end

    factory :category_type_income do
      id { CategoryType.income }
      name { "income" }
    end

    factory :category_type_expense do
      id { CategoryType.expense }
      name { "spending" }
    end
  end
end
