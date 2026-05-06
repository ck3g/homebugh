class AddUpdatedAtIndexesToSyncableTables < ActiveRecord::Migration[8.1]
  def change
    add_index :accounts, :updated_at unless index_exists?(:accounts, :updated_at)
    add_index :transactions, :updated_at unless index_exists?(:transactions, :updated_at)
    add_index :cash_flows, :updated_at unless index_exists?(:cash_flows, :updated_at)
    add_index :budgets, :updated_at unless index_exists?(:budgets, :updated_at)
    add_index :recurring_payments, :updated_at unless index_exists?(:recurring_payments, :updated_at)
    add_index :recurring_cash_flows, :updated_at unless index_exists?(:recurring_cash_flows, :updated_at)
    # categories already has updated_at index
  end
end
