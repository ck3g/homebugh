class AddRecoverableToUsers < ActiveRecord::Migration
  def change
    ## Recoverable
    # Travis failing with that
    # add_column :users, :reset_password_sent_at, :datetime
  end
end
