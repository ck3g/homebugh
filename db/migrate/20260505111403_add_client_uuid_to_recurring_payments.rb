class AddClientUuidToRecurringPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :recurring_payments, :client_uuid, :string
    add_index :recurring_payments, [:user_id, :client_uuid], unique: true, where: "client_uuid IS NOT NULL", name: "index_recurring_payments_on_user_id_and_client_uuid"
  end
end
