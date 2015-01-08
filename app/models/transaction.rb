class Transaction < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  belongs_to :account

  validates :account_id, :category_id, presence: true
  validates :summ, presence: true, numericality: {
    greater_than_or_equal_to: 0.01
  }

  delegate :name, to: :category, prefix: true
  delegate :category_type_id, to: :category, prefix: false, allow_nil: true
  delegate :name, :currency_id, to: :account, prefix: true

  after_create :affect_on_account_after_create
  before_destroy :affect_on_account_before_destroy

  scope :category, ->(category_id) { where(category_id: category_id) }

  def income?
    category_type_id == CategoryType.income
  end

  private
  def affect_on_account_after_create
    Transaction.transaction do
      account.deposit(summ) if income?
      account.withdrawal(summ) unless income?
    end
  end

  def affect_on_account_before_destroy
    Transaction.transaction do
      account.withdrawal(summ) if income?
      account.deposit(summ) unless income?
    end
  end
end
