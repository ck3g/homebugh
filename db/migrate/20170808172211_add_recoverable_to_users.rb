class AddRecoverableToUsers < ActiveRecord::Migration
  def change
    ## Recoverable
    add_column :users, :reset_password_sent_at, :datetime
  end
end
