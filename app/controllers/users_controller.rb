class UsersController < ApplicationController
  def delete; end

  def show; end

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
