class RenameTypeToCategoryType < ActiveRecord::Migration
  def self.up
    rename_table :types, :category_types
    rename_column :categories, :type_id, :category_type_id
  end

  def self.down
    rename_table :category_types, :types
    rename_column :categories, :category_type_id, :type_id
  end
end
