class Transaction < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  belongs_to :account

  validates :summ, :presence => true, :numericality => true
  validate :cannot_be_less_than_0_01

  def cannot_be_less_than_0_01
    errors.add(:summ, I18n.t('common.cannot_be_less_than', :value => 0.01)) if summ.to_f < 0.01
  end

  def extended_save
    raise ActiveRecord::RecordNotFound if self.category.nil?
    account = Account.where(:user_id => self.user_id).find(self.account_id)
    summ = self.summ || 0
    Transaction.transaction do
      account.deposit(summ) if self.category.category_type_id == CategoryType.income
      account.withdrawal(summ) if self.category.category_type_id == CategoryType.spending

      self.save
    end
  end

  def extended_update_attributes(params)
    prev_funds = self.summ
    prev_account_id = self.account_id
    prev_type_id = self.category.category_type_id

    curr_funds = params[:summ]
    curr_account_id = params[:account_id]

    Transaction.transaction do
      prev_account = Account.where(:user_id => self.user_id).find(prev_account_id)
      prev_account.deposit(prev_funds.to_f) if prev_type_id == CategoryType.spending
      prev_account.withdrawal(prev_funds.to_f) if prev_type_id == CategoryType.income

      curr_type_id = Transaction.where(:user_id => self.user_id).find(self.id).category.category_type_id
      curr_account = Account.where(:user_id => self.user_id).find(curr_account_id)
      curr_account.deposit(curr_funds.to_f) if curr_type_id == CategoryType.income
      curr_account.withdrawal(curr_funds.to_f) if curr_type_id == CategoryType.spending

      self.update_attributes(params)
    end
  end

  def extended_destroy
    account = Account.where( :user_id => self.user_id ).find( self.account_id )
    Transaction.transaction do
      account.withdrawal(self.summ) if self.category.category_type_id == CategoryType.income
      account.deposit(self.summ) if self.category.category_type_id == CategoryType.spending

      self.destroy
    end
  end
end
