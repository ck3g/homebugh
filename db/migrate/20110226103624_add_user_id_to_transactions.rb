class AddUserIdToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :user_id, :integer
  end

  def self.down
    remove_column :transactions, :user_id
  end
end
