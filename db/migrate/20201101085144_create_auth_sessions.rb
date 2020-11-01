class CreateAuthSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :auth_sessions do |t|
      t.bigint :user_id, null: false
      t.string :token, null: false
      t.datetime :expired_at, null: false

      t.timestamps
    end
    add_index :auth_sessions, :user_id
    add_index :auth_sessions, :token, unique: true
  end
end
