class AddIndexesToCashFlows < ActiveRecord::Migration
  def change
    add_index :cash_flows, :user_id
    add_index :cash_flows, :from_account_id
    add_index :cash_flows, :to_account_id
  end
end
