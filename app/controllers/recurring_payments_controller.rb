class RecurringPaymentsController < ApplicationController
  authorize_resource

  before_action :find_recurring_payment, only: [:edit, :update, :destroy, :move_to_next_payment, :create_transaction]

  def index
    @recurring_payments = current_user.recurring_payments.upcoming
  end

  def new
    @recurring_payment = current_user.recurring_payments.new(**new_safe_params)
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

  def move_to_next_payment
    @recurring_payment.move_to_next_payment
    redirect_to recurring_payments_path
  end

  def create_transaction
    if current_user.transactions.create(**transaction_params_from(@recurring_payment))
      @recurring_payment.move_to_next_payment
      redirect_to transactions_path, notice: t('parts.transactions.successfully_created')
    else
      redirect_to recurring_payments_path, alert: t('parts.recurring_payments.cannot_create_transaction')
    end
  end

  private

  def find_recurring_payment
    @recurring_payment ||= current_user.recurring_payments.find(params[:id])
  end

  def recurring_payment_params
    [:title, :account_id, :category_id, :amount, :frequency, :frequency_amount, :next_payment_on]
  end

  def safe_params
    params.require(:recurring_payment).permit(*recurring_payment_params)
  end

  def new_safe_params
    params.permit(*recurring_payment_params)
  end

  def transaction_params_from(recurring_payment)
    {
      summ: recurring_payment.amount,
      comment: recurring_payment.title,
      category: recurring_payment.category,
      account: recurring_payment.account
    }
  end
end
