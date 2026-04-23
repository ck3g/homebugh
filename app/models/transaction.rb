class Transaction < ApplicationRecord
  include Categorizable

  belongs_to :user
  belongs_to :account, touch: true

  validates :account_id, :category_id, presence: true
  validates :summ, presence: true, numericality: {
    greater_than_or_equal_to: 0.01
  }

  delegate :name, to: :category, prefix: true
  delegate :name, :currency_id, to: :account, prefix: true

  after_create -> { AccountBalance.apply(self) }
  before_destroy -> { AccountBalance.reverse(self) }

  scope :account, ->(account_id) { where(account_id: account_id) }
  scope :currency, -> currency_id {
    joins(:account).where(:'accounts.currency_id' => currency_id)
  }
  scope :created_between, -> date_from, date_to {
    where(created_at: date_from..date_to)
  }
end
