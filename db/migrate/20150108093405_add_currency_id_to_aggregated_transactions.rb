class AddCurrencyIdToAggregatedTransactions < ActiveRecord::Migration
  def change
    add_column :aggregated_transactions, :currency_id, :integer
    add_index :aggregated_transactions, :currency_id
  end
end
