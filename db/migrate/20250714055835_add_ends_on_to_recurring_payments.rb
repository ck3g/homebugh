class AddEndsOnToRecurringPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :recurring_payments, :ends_on, :date
  end
end
