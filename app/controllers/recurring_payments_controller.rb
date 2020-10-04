class RecurringPaymentsController < ApplicationController
  authorize_resource

  before_action :find_recurring_payment, only: [:destroy]

  def index
    @recurring_payments = current_user.recurring_payments
  end

  def destroy
    @recurring_payment.destroy
    redirect_to recurring_payments_path
  end

  private

  def find_recurring_payment
    @recurring_payment ||= current_user.recurring_payments.find(params[:id])
  end
end
