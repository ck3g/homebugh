class AccountsController < ApplicationController
  authorize_resource
  before_filter :find_account, only: [:show, :edit, :update, :destroy]

  def index
    @accounts = current_user.accounts.by_recently_used.page(params[:page])
  end

  def new
    @account = Account.new
  end

  def create
    @account = current_user.accounts.new safe_params

    if @account.save
      redirect_to accounts_path, notice: t('parts.accounts.successfully_created')
    else
      render "new"
    end
  end

  def update
    if @account.update_attributes safe_params
      redirect_to accounts_path, notice: t('parts.accounts.successfully_updated')
    else
      render "edit"
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_url
  end

  private
  def find_account
    @account = current_user.accounts.find(params[:id])
  end

  def safe_params
    params.require(:account).permit(:name, :currency_id)
  end
end
