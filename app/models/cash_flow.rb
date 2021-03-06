class CashFlow < ApplicationRecord
  belongs_to :user
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'

  validates :user_id, :from_account_id, :to_account_id, presence: true
  validates :amount, presence: true, numericality: {
    greater_than_or_equal_to: 0.01
  }
  validate :accounts_cannot_be_equal

  delegate :name, to: :from_account, prefix: true
  delegate :name, to: :to_account, prefix: true

  after_create :affect_on_accounts_after_create
  before_destroy :affect_on_accounts_before_destroy

  def accounts_cannot_be_equal
    if from_account_id == to_account_id
      errors.add(:to_account_id, I18n.t('parts.cash_flows.accounts_cannot_be_equal'))
    end
  end

  def from_account_id=(account)
    from_account_id_will_change!
    super
  end

  private
  def affect_on_accounts_after_create
    FundsTransferService.new(from_account, to_account).
      transfer _initial_amount, amount
  end

  def affect_on_accounts_before_destroy
    FundsTransferService.new(to_account, from_account).
      transfer amount, _initial_amount
  end

  def _initial_amount
    initial_amount.presence || amount
  end
end
