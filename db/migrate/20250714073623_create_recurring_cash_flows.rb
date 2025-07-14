class CreateRecurringCashFlows < ActiveRecord::Migration[8.0]
  def change
    create_table :recurring_cash_flows do |t|
      t.bigint :user_id, null: false
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }
      t.references :to_account, null: false, foreign_key: { to_table: :accounts }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :frequency_amount, null: false
      t.integer :frequency, default: 0, null: false
      t.date :next_transfer_on, null: false
      t.date :ends_on

      t.timestamps
    end
  end
end
