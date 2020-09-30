class AggregatedTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :category
  belongs_to :category_type
  belongs_to :currency

  validates :user, :category, :category_type_id, :period_started_at,
    :period_ended_at, presence: true
  validates :amount, presence: true, numericality: true

  scope :income, -> { where category_type_id: CategoryType.income }
  scope :spending, -> { where category_type_id: CategoryType.spending }
  scope :month, -> month {
    where period_started_at: month, period_ended_at: month.end_of_month
  }
  scope :currency, -> currency_id { where currency_id: currency_id }
end
