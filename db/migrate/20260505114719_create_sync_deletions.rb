class CreateSyncDeletions < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_deletions do |t|
      t.string :resource_type, null: false
      t.bigint :resource_id, null: false
      t.bigint :user_id, null: false
      t.datetime :deleted_at, null: false

      t.datetime :created_at
    end

    add_index :sync_deletions, [:user_id, :deleted_at]
  end
end
