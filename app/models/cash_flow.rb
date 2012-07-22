class CashFlow < ActiveRecord::Base
  attr_accessible :from_account_id, :to_account_id, :amount, :user_id

  belongs_to :user
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'

  validates :amount, :user_id, :from_account_id, :to_account_id, presence: true
  validates :amount, numericality: true
  validate :cannot_be_less_than_0_01, unless: 'amount.nil?'
  validate :accounts_cannot_be_equal

  delegate :name, to: :from_account, prefix: true
  delegate :name, to: :to_account, prefix: true

  after_create :affect_on_accounts_after_create
  before_destroy :affect_on_accounts_before_destroy

  def cannot_be_less_than_0_01
    errors.add(:amount, I18n.t('common.cannot_be_less_than', value: 0.01)) if amount < 0.01
  end

  def accounts_cannot_be_equal
    errors.add(:to_account_id, I18n.t('parts.cash_flows.accounts_cannot_be_equal')) if from_account_id == to_account_id
  end

  def from_account_id=(account)
    from_account_id_will_change!
    super
  end

  private
  def affect_on_accounts_after_create
    CashFlow.transaction do
      from_account.withdrawal(amount)
      to_account.deposit(amount)
    end
  end

  def affect_on_accounts_before_destroy
    CashFlow.transaction do
      from_account.deposit(amount)
      to_account.withdrawal(amount)
    end
  end
end
