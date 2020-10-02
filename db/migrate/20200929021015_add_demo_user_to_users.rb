class AddDemoUserToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :demo_user, :boolean, default: false
  end
end
