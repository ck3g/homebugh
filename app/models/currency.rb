class Currency < ApplicationRecord
  include Orderable

  has_many :accounts
  has_many :aggregated_transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: true }
end
