class CreateRecurringCashFlows < ActiveRecord::Migration[8.0]
  def change
    create_table :recurring_cash_flows do |t|
      t.bigint :user_id, null: false
      t.bigint :from_account_id, null: false
      t.bigint :to_account_id, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :frequency_amount, null: false
      t.integer :frequency, default: 0, null: false
      t.date :next_transfer_on, null: false
      t.date :ends_on

      t.timestamps
    end
    add_index :recurring_cash_flows, :user_id
    add_index :recurring_cash_flows, :from_account_id
    add_index :recurring_cash_flows, :to_account_id
  end
end
