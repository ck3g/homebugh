class AddCurrencyIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :currency_id, :integer
    add_index :accounts, :currency_id

    Account.reset_column_information
    Account.update_all currency_id: Currency.first.id
  end
end
