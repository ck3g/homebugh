class RecurringCashFlowsController < ApplicationController
  authorize_resource

  before_action :find_recurring_cash_flow, only: [:edit, :update, :destroy, :move_to_next_transfer, :perform_transfer]

  def index
    @active_recurring_cash_flows = current_user.recurring_cash_flows.active.upcoming
    @ended_recurring_cash_flows = current_user.recurring_cash_flows.ended.upcoming
  end

  def new
    @recurring_cash_flow = current_user.recurring_cash_flows.new(**new_safe_params)
  end

  def create
    @recurring_cash_flow = current_user.recurring_cash_flows.new(safe_params)
    if @recurring_cash_flow.save
      redirect_to recurring_cash_flows_path, notice: t('parts.recurring_cash_flows.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @recurring_cash_flow.update(safe_params)
      redirect_to recurring_cash_flows_path, notice: t('parts.recurring_cash_flows.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @recurring_cash_flow.destroy
    redirect_to recurring_cash_flows_path
  end

  def move_to_next_transfer
    @recurring_cash_flow.move_to_next_transfer
    redirect_to recurring_cash_flows_path
  end

  def perform_transfer
    if current_user.cash_flows.create(**cash_flow_params_from(@recurring_cash_flow))
      @recurring_cash_flow.move_to_next_transfer
      redirect_to cash_flows_path, notice: t('parts.cash_flows.successfully_created')
    else
      redirect_to recurring_cash_flows_path, alert: t('parts.recurring_cash_flows.cannot_perform_transfer')
    end
  end

  private

  def find_recurring_cash_flow
    @recurring_cash_flow ||= current_user.recurring_cash_flows.find(params[:id])
  end

  def recurring_cash_flow_params
    [:from_account_id, :to_account_id, :amount, :frequency, :frequency_amount, :next_transfer_on, :ends_on]
  end

  def safe_params
    params.require(:recurring_cash_flow).permit(*recurring_cash_flow_params)
  end

  def new_safe_params
    params.permit(*recurring_cash_flow_params)
  end

  def cash_flow_params_from(recurring_cash_flow)
    {
      amount: recurring_cash_flow.amount,
      from_account: recurring_cash_flow.from_account,
      to_account: recurring_cash_flow.to_account
    }
  end
end
