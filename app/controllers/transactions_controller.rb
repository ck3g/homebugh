class TransactionsController < ApplicationController
  respond_to :html, :json

  authorize_resource
  before_action :find_transaction, only: [:destroy, :update]
  before_action :find_categories, only: [:new, :create]
  before_action :find_accounts, only: [:new, :create]

  has_scope :category
  has_scope :account

  def index
    @transactions = apply_scopes(current_user.transactions.includes(:category, :account)).order('created_at desc').page(params[:page])
    @recurring_payments = current_user.recurring_payments.upcoming.due
  end

  def new
    @transaction = current_user.transactions.new account_id: session[:account_id], category_id: session[:category_id]
  end

  def create
    @transaction = current_user.transactions.new create_params
    if @transaction.save
      session[:account_id] = @transaction.account_id
      session[:category_id] = @transaction.category_id
      redirect_to transactions_path, notice: t('parts.transactions.successfully_created')
    else
      render "new"
    end
  end

  def update
    @transaction.update(update_params)
    respond_to do |format|
      format.html { redirect_to transactions_path }
      format.json { render json: @transaction }
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

  def create_params
    params.require(:transaction).permit(:account_id, :category_id, :summ, :comment)
  end

  def update_params
    params.require(:transaction).permit(:comment)
  end
end
