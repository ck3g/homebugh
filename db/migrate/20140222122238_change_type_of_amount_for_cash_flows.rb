class ChangeTypeOfAmountForCashFlows < ActiveRecord::Migration
  def up
    change_column :cash_flows, :amount, :decimal, null: false, precision: 10, scale: 2
  end

  def down
    change_column :cash_flows, :amount, :float, null: false
  end
end
