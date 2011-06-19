class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name, :limit => 50, :null => false
      t.integer :user_id, :null => false
      t.float :funds, :default => 0.0

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
