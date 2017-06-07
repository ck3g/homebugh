class Currency < ActiveRecord::Base
  has_many :accounts
  has_many :aggregated_transactions, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :by_recently_used, -> { order(updated_at: :desc) }
end
