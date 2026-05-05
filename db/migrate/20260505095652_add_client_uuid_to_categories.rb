class AddClientUuidToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :client_uuid, :string
    add_index :categories, [:user_id, :client_uuid], unique: true, where: "client_uuid IS NOT NULL", name: "index_categories_on_user_id_and_client_uuid"
  end
end
