module ApplicationHelper
  def get_total
    #incoming = Transaction.all(:conditions => 'categories.type_id = 1', :include => :category)
    incoming = Transaction.includes( :category ).where( 'categories.type_id' => 1, :user_id => current_user.id )
    income_sum = 0
    incoming.each do |income|
      income_sum += income.summ.to_f
    end

    #charges = Transaction.all(:conditions => 'categories.type_id = 2', :include => :category)
    charges = Transaction.includes( :category ).where( 'categories.type_id' => 2, :user_id => current_user.id )
    charge_sum = 0
    charges.each do |charge|
      charge_sum += charge.summ.to_f
    end

    income_sum.to_f - charge_sum.to_f
  end
end
