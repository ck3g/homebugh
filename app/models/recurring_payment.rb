class RecurringPayment < ApplicationRecord
  belongs_to :user
  belongs_to :category
  belongs_to :account

  validates :title, :user, :category, :account, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :frequency_amount, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  enum frequency: { daily: 0, weekly: 1, monthly: 2, yearly: 3 }
end
