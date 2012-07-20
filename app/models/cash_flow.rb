class CashFlow < ActiveRecord::Base
  attr_accessible :from_account_id, :to_account_id, :amount, :user_id

  belongs_to :user
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'

  validates :amount, :user_id, :from_account_id, :to_account_id, presence: true
  validates :amount, numericality: true
  validate :cannot_be_less_than_0_01, unless: 'amount.nil?'
  validate :accounts_cannot_be_equal

  def cannot_be_less_than_0_01
    errors.add(:amount, I18n.t('common.cannot_be_less_than', value: 0.01)) if amount < 0.01
  end

  def accounts_cannot_be_equal
    errors.add(:to_account_id, I18n.t('parts.cash_flows.accounts_cannot_be_equal')) if from_account_id == to_account_id
  end

  def move_funds
    CashFlow.transaction do
      cash_flow = CashFlow.new({ from_account_id: self.from_account_id, to_account_id: self.to_account_id, amount: self.amount, user_id: self.user_id })

      from_account = user.accounts.find(self.from_account_id)
      from_account.withdrawal(self.amount.to_f)

      to_account = user.accounts.find(self.to_account_id)
      to_account.deposit(self.amount.to_f)

      cash_flow.save
    end
  end

  def extended_destroy
    CashFlow.transaction do
      self.destroy

      from_account = Account.find(self.from_account_id)
      from_account.deposit(self.amount)

      to_account = Account.find(self.to_account_id)
      to_account.withdrawal(self.amount)
    end
  end

  def extended_update_attributes(params)
    CashFlow.transaction do
      old_from_account = user.accounts.find(self.from_account_id.to_i)
      old_to_account = user.accounts.find(self.to_account_id.to_i)
      old_from_account.deposit(self.amount.to_f)
      old_to_account.withdrawal(self.amount.to_f)

      new_from_account = user.accounts.find(params[:from_account_id].to_i)
      new_to_account = user.accounts.find(params[:to_account_id].to_i)
      new_from_account.withdrawal(params[:amount].to_f)
      new_to_account.deposit(params[:amount].to_f)

      self.update_attributes(params)
    end
  end
end
