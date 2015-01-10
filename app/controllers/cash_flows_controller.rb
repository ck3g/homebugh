class CashFlowsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_cash_flow, only: [:destroy]
  before_filter :find_accounts, only: [:new, :create, :destroy]

  def index
    @cash_flows = current_user.cash_flows.includes(:from_account, :to_account).order('created_at desc').page(params[:page])
  end

  def new
    @cash_flow = current_user.cash_flows.new from_account_id: session[:from_account_id], to_account_id: session[:to_account_id]
  end

  def create
    @cash_flow = current_user.cash_flows.new safe_params

    if @cash_flow.save
      session[:from_account_id] = @cash_flow.from_account_id
      session[:to_account_id] = @cash_flow.to_account_id
      redirect_to cash_flows_path, notice: t('parts.cash_flows.successfully_updated')
    else
      render "new"
    end
  end

  def destroy
    @cash_flow.destroy
    redirect_to cash_flows_path
  end

  private
  def find_cash_flow
    @cash_flow = current_user.cash_flows.find(params[:id])
  end

  def find_accounts
    @accounts = current_user.accounts.active
  end

  def safe_params
    params.require(:cash_flow).permit(
      :from_account_id, :to_account_id, :initial_amount, :amount
    )
  end
end
