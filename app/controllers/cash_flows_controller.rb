class CashFlowsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_cash_flow, only: [:show, :edit, :update, :destroy]
  before_filter :find_accounts, only: [:new, :edit, :create, :update, :destroy]

  def index
    @cash_flows = current_user.cash_flows.includes(:from_account, :to_account).order('created_at desc').limit(50)
  end

  def new
    @cash_flow = current_user.cash_flows.new
  end

  def edit
  end

  def create
    @cash_flow = current_user.cash_flows.new(params[:cash_flow])
    @cash_flow.valid?

    if @cash_flow.move_funds
      redirect_to cash_flows_path, notice: t('parts.cash_flows.successfully_updated')
    else
      render "new"
    end
  end

  def update
    if @cash_flow.extended_update_attributes(params[:cash_flow])
      redirect_to cash_flows_path, notice: t('parts.cash_flows.successfully_updated')
    else
      render "edit"
    end
  end

  def destroy
    @cash_flow.extended_destroy
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
