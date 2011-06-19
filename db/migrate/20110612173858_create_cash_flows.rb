class CreateCashFlows < ActiveRecord::Migration
  def self.up
    create_table :cash_flows do |t|
      t.integer :user_id, :null => false
      t.integer :from_account_id, :null => false
      t.integer :to_account_id, :null => false
      t.float :amount, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :cash_flows
  end
end
