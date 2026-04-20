class AddStatusToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :status, :string, default: "active", null: false
    add_index :categories, :status
  end
end
