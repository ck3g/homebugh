class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_transaction, only: [:destroy]
  before_filter :find_categories, only: [:new, :create]
  before_filter :find_accounts, only: [:new, :create]
  after_filter :expire_statistics_cache, only: [:create, :destroy]

  def index
    @transactions = current_user.transactions.includes(:category, :account).order('created_at desc').limit(50)
  end

  def new
    @transaction = current_user.transactions.new account_id: session[:account_id], category_id: session[:category_id]
  end

  def create
    @transaction = current_user.transactions.new(params[:transaction])
    if @transaction.save
      session[:account_id] = @transaction.account_id
      session[:category_id] = @transaction.category_id
      redirect_to transactions_path, notice: t('parts.transactions.successfully_created')
    else
      render "new"
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_path
  end

  private
  def find_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def find_categories
    @categories = current_user.categories.active
  end

  def find_accounts
    @accounts = current_user.accounts
  end
end
