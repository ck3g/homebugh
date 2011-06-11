module ApplicationHelper
  def get_total
    incoming = Transaction.includes( :category ).where( 'categories.category_type_id' => 1, :user_id => current_user.id )
    income_sum = 0
    incoming.each do |income|
      income_sum += income.summ.to_f
    end

    spending = Transaction.includes( :category ).where( 'categories.category_type_id' => 2, :user_id => current_user.id )
    spending_sum = 0
    spending.each do |spend|
      spending_sum += spend.summ.to_f
    end

    income_sum.to_f - spending_sum.to_f
  end
end
