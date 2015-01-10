class AddStatusToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :status, :string, null: false, default: 'active'
    add_index :accounts, :status
  end
end
