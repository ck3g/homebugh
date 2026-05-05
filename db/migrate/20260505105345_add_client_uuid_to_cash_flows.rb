class AddClientUuidToCashFlows < ActiveRecord::Migration[8.1]
  def change
    add_column :cash_flows, :client_uuid, :string
    add_index :cash_flows, [:user_id, :client_uuid], unique: true, where: "client_uuid IS NOT NULL", name: "index_cash_flows_on_user_id_and_client_uuid"
  end
end
