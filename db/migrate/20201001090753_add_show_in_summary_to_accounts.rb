class AddShowInSummaryToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :show_in_summary, :boolean, default: true
  end
end
