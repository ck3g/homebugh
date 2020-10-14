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

  after_create :affect_on_account_after_create
  before_destroy :affect_on_account_before_destroy

  scope :account, ->(account_id) { where(account_id: account_id) }
  scope :currency, -> currency_id {
    joins(:account).where(:'accounts.currency_id' => currency_id)
  }
  scope :created_between, -> date_from, date_to {
    where(created_at: date_from..date_to)
  }

  private

  def affect_on_account_after_create
    Transaction.transaction do
      income? ? account.deposit(summ) : account.withdrawal(summ)
    end
  end

  def affect_on_account_before_destroy
    Transaction.transaction do
      income? ? account.withdrawal(summ) : account.deposit(summ)
    end
  end
end
