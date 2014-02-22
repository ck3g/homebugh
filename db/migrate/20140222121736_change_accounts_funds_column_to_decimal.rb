class ChangeAccountsFundsColumnToDecimal < ActiveRecord::Migration
  def up
    change_column :accounts, :funds, :decimal, default: 0, precision: 10, scale: 2
  end

  def down
    change_column :accounts, :funds, :float, default: 0
  end
end
