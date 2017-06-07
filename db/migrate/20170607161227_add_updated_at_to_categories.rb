class AddUpdatedAtToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :updated_at, :datetime
    add_index :categories, :updated_at
  end
end
