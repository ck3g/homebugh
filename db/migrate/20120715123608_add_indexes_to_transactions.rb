class AddIndexesToTransactions < ActiveRecord::Migration
  def change
    add_index :transactions, :category_id
    add_index :transactions, :user_id
    add_index :transactions, :account_id
  end
end
