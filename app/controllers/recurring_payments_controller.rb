class RecurringPaymentsController < ApplicationController
  authorize_resource

  before_action :find_recurring_payment, only: [:edit, :update, :destroy]

  def index
    @recurring_payments = current_user.recurring_payments.upcoming
  end

  def new
    @recurring_payment = current_user.recurring_payments.new(
      category_id: params[:category_id],
      account_id: params[:account_id],
      amount: params[:amount],
      frequency: params[:frequency],
      frequency_amount: params[:frequency_amount],
      next_payment_on: params[:next_payment_on]
    )
  end

  def create
    @recurring_payment = current_user.recurring_payments.new(safe_params)
    if @recurring_payment.save
      redirect_to recurring_payments_path, notice: t('parts.recurring_payments.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @recurring_payment.update(safe_params)
      redirect_to recurring_payments_path, notice: t('parts.recurring_payments.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @recurring_payment.destroy
    redirect_to recurring_payments_path
  end

  private

  def find_recurring_payment
    @recurring_payment ||= current_user.recurring_payments.find(params[:id])
  end

  def safe_params
    params.require(:recurring_payment).permit(:title, :account_id, :category_id, :amount, :frequency, :frequency_amount, :next_payment_on)
  end
end
