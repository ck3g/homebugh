class AddInitialAmountToCashFlows < ActiveRecord::Migration
  def change
    add_column :cash_flows, :initial_amount, :decimal, precision: 10, scale: 2
  end
end
