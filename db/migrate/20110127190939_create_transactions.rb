class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :category_id
      t.float :summ
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
