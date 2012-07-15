class AddIndexesToCategories < ActiveRecord::Migration
  def change
    add_index :categories, :category_type_id
    add_index :categories, :user_id
  end
end
