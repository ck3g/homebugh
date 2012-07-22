class CashFlowsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_cash_flow, only: [:destroy]
  before_filter :find_accounts, only: [:new, :create, :destroy]

  def index
    @cash_flows = current_user.cash_flows.includes(:from_account, :to_account).order('created_at desc').limit(50)
  end

  def new
    @cash_flow = current_user.cash_flows.new
  end

  def create
    @cash_flow = current_user.cash_flows.new(params[:cash_flow])

    if @cash_flow.save
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
    @accounts = current_user.accounts
  end
end
