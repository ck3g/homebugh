module ApplicationHelper
  def get_number_to_currency( number )
    number_to_currency number, :unit => 'лей', :format => '%n %u'
  end

  def get_account_funds( account_id, user_id = nil )
    user_id ||= current_user.id
    Account.where( :user_id => user_id ).find( account_id ).funds
  end

  def get_total_funds
    total_funds = 0
    Account.where( :user_id => current_user.id ).each do |account|
      total_funds += get_account_funds( account.id ).to_f
    end

    total_funds
  end

  def accounts_recalculate
    Account.all.each do |account|
      account.funds = get_total_income( account.id, account.user_id ).to_f - get_total_spending( account.id, account.user_id ).to_f
      account.save
    end
  end

  def get_total_income( account_id, user_id = nil )
    get_total_by_type( 1, account_id, user_id )
  end

  def get_total_spending( account_id, user_id = nil )
    get_total_by_type( 2, account_id, user_id )
  end

  private

  def get_total_by_type( type_id, account_id, user_id = nil )
    user_id ||= current_user.id
    transactions = Transaction.includes( :category ).where( 'categories.category_type_id' => type_id, :user_id => user_id, :account_id => account_id )
    total_funds = 0
    transactions.each do |transaction|
      total_funds += transaction.summ.to_f
    end

    total_funds
  end
end
