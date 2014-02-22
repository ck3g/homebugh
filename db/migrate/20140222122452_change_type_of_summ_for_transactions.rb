class ChangeTypeOfSummForTransactions < ActiveRecord::Migration
  def up
    change_column :transactions, :summ, :decimal, default: 0, null: false, precision: 10, scale: 2
  end

  def down
    change_column :transactions, :summ, :float
  end
end
