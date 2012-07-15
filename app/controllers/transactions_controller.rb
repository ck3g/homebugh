class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_transaction, only: [:show, :edit, :update, :destroy]
  before_filter :find_categories, only: [:new, :edit, :create, :update]
  before_filter :find_accounts, only: [:new, :edit, :create, :update]

  def index
    @transactions = current_user.transactions.includes(:category, :account).order('created_at desc').limit(50)
  end

  def show
  end

  def new
    @transaction = current_user.transactions.new
  end

  def edit
  end

  def create
    @transaction = current_user.transactions.new(params[:transaction])
    if @transaction.extended_save
      redirect_to transactions_path, notice: t('parts.transactions.successfully_created')
    else
      render "new"
    end
  end

  def update
    if @transaction.extended_update_attributes(params[:transaction])
      redirect_to transactions_path, notice: t('parts.transactions.successfully_updated')
    else
      render "edit"
    end
  end

  def destroy
    @transaction.extended_destroy
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
