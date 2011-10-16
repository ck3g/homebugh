class AddInactiveToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :inactive, :boolean, :default => false
  end

  def self.down
    remove_column :categories, :inactive
  end
end
