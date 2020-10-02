class RecurringPaymentsController < ApplicationController
  authorize_resource

  def index
    @recurring_payments = current_user.recurring_payments
  end
end
