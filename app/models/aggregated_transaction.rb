class AggregatedTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :category_type

  validates :user, :category, :category_type_id, :period_started_at,
    :period_ended_at, presence: true
  validates :amount, presence: true, numericality: true
end
