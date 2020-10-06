class RecurringPaymentsController < ApplicationController
  authorize_resource

  before_action :find_recurring_payment, only: [:destroy]

  def index
    @recurring_payments = current_user.recurring_payments
  end

  def new
    @recurring_payment = current_user.recurring_payments.new
  end

  def create
    @recurring_payment = current_user.recurring_payments.new(create_params)
    if @recurring_payment.save
      redirect_to recurring_payments_path, notice: t('parts.recurring_payments.successfully_created')
    else
      render :new
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

  def create_params
    params.require(:recurring_payment).permit(:title, :account_id, :category_id, :amount, :frequency, :frequency_amount, :next_payment_on)
  end
end
