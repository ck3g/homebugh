class Transaction < ActiveRecord::Base
	belongs_to :category
  belongs_to :user
  belongs_to :account
  
  validates_presence_of :summ
  validates_numericality_of :summ
  validate :sum_cannot_be_less_than_0_01, :unless => 'summ.nil?'
  
  def sum_cannot_be_less_than_0_01
    errors.add( :summ, I18n.t( 'common.cannot_be_less_than', :value => 0.01 ) ) if (summ < 0.01)
  end

  def extended_save
    account = Account.where( :user_id => self.user_id ).find( self.account_id )
    Transaction.transaction do
      self.save!
      account.deposit( self.summ ) if self.category.category_type_id == 1
      account.withdrawal( self.summ ) if self.category.category_type_id == 2
    end
    return true
  rescue
    return false
  end

  def extended_update_attributes( params )
    prev_funds = self.summ
    prev_account_id = self.account_id
    prev_type_id = self.category.category_type_id

    curr_funds = params[:summ]
    curr_account_id = params[:account_id]

    Transaction.transaction do
      prev_account = Account.where( :user_id => self.user_id ).find( prev_account_id )
      prev_account.deposit( prev_funds.to_f ) if prev_type_id == 2
      prev_account.withdrawal( prev_funds.to_f ) if prev_type_id == 1

      self.update_attributes( params )
      curr_type_id = Transaction.where( :user_id => self.user_id ).find( self.id ).category.category_type_id
      curr_account = Account.where( :user_id => self.user_id ).find( curr_account_id )
      curr_account.deposit( curr_funds.to_f ) if curr_type_id == 1
      curr_account.withdrawal( curr_funds.to_f ) if curr_type_id == 2

    end
    return true
  rescue
    return false
  end

  def extended_destroy
    account = Account.where( :user_id => self.user_id ).find( self.account_id )
    Transaction.transaction do
      self.destroy
      account.withdrawal( self.summ ) if self.category.category_type_id == 1
      account.deposit( self.summ ) if self.category.category_type_id == 2
    end
    return true
  rescue
    return false
  end
end
