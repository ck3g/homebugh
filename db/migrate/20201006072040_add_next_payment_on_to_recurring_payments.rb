class AddNextPaymentOnToRecurringPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_payments, :next_payment_on, :date
  end
end
