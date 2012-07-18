class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_account, only: [:show, :edit, :update, :destroy]

  def index
    @accounts = current_user.accounts
  end

  def show
  end

  def new
    @account = current_user.accounts.new
  end

  def edit
  end

  def create
    @account = current_user.accounts.new(params[:account])

    if @account.save
      redirect_to accounts_path, notice: t('parts.accounts.successfully_created')
    else
      render "new"
    end
  end

  def update
    if @account.update_attributes(params[:account])
      redirect_to accounts_path, notice: t('parts.accounts.successfully_updated')
    else
      render "edit"
    end
  end

  def destroy
    @account.destroy if @account.funds == 0.0
    redirect_to accounts_url
  end

  private
  def find_account
    @account = current_user.accounts.find(params[:id])
  end
end
