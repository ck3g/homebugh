class CreateRecurringPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :recurring_payments do |t|
      t.string :title, null: false
      t.integer :user_id, null: false, index: true
      t.integer :category_id, null: false, index: true
      t.integer :account_id, null: false, index: true
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.integer :frequency_amount, null: false
      t.integer :frequency, null: false, default: 0

      t.timestamps
    end
  end
end
