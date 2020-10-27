# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :aggregated_transaction do
    user
    category
    currency
    category_type_id { CategoryType.spending }
    amount { 503 }
    period_started_at { 1.month.ago.beginning_of_month }
    period_ended_at { 1.month.ago.end_of_month }
  end
end
