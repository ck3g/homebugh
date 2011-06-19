class CashFlow < ActiveRecord::Base
  belongs_to :user
  belongs_to :from_account, :class_name => 'Account'
  belongs_to :to_account, :class_name => 'Account'

  validates_presence_of :amount
  validates_numericality_of :amount
  validate :amount_cannot_be_less_than_0_01, :unless => 'amount.nil?'
  validate :accounts_cannot_be_equal

  def amount_cannot_be_less_than_0_01
    errors.add( :amount, I18n.t( 'common.cannot_be_less_than', :value => 0.01 ) ) if (amount < 0.01)
  end

  def accounts_cannot_be_equal
    errors.add( :to_account_id, I18n.t( 'parts.cash_flows.accounts_cannot_be_equal' ) ) if :from_account_id == :to_account_id
  end

  def move_funds
    CashFlow.transaction do
      cash_flow = CashFlow.new({:from_account_id => self.from_account_id, :to_account_id => self.to_account_id, :amount => self.amount, :user_id => self.user_id})
      cash_flow.save!

      from_account = Account.where( :user_id => self.user_id ).find( self.from_account_id )
      from_account.withdrawal( self.amount.to_f )

      to_account = Account.where( :user_id => self.user_id ).find( self.to_account_id )
      to_account.deposit( self.amount.to_f )
    end
    return true
  rescue
    return false
  end

  def extended_destroy
    CashFlow.transaction do
      self.destroy

      from_account = Account.find( self.from_account_id )
      from_account.deposit( self.amount )

      to_account = Account.find( self.to_account_id )
      to_account.withdrawal( self.amount )
    end
    return true
  rescue
    return false
  end

  def extended_update_attributes( params )
    user_id = self.user_id

    CashFlow.transaction do
      old_from_account = Account.where( :user_id => user_id).find( self.from_account_id.to_i )
      old_to_account = Account.where( :user_id => user_id).find( self.to_account_id.to_i )
      old_from_account.deposit( self.amount.to_f )
      old_to_account.withdrawal( self.amount.to_f )

      self.update_attributes( params )
      new_from_account = Account.where( :user_id => user_id).find( params[:from_account_id].to_i )
      new_to_account = Account.where( :user_id => user_id).find( params[:to_account_id].to_i )
      new_from_account.withdrawal( params[:amount].to_f )
      new_to_account.deposit( params[:amount].to_f )
    end
    return true
  rescue
    return false
  end
end
