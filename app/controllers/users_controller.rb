class UsersController < ApplicationController
  def delete; end

  def show
    # Get user statistics for profile page
    @user_stats = {
      accounts_count: current_user.accounts.count,
      transactions_count: current_user.transactions.count,
      categories_count: current_user.categories.count,
      budgets_count: current_user.budgets.count,
      currencies_count: current_user.currencies.count,
      first_transaction_date: current_user.transactions.order(:created_at).first&.created_at
    }
  end

  def destroy
    if current_user.valid_password?(user_password)
      current_user.destroy
      redirect_to root_path
    else
      current_user.errors.add(:password)
      render :delete
    end
  end

  private

  def user_password
    params.require(:user).permit(:password)[:password]
  end
end
