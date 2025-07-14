class RecurringCashFlowDecorator < Draper::Decorator
  delegate_all

  def frequency
    I18n.t("parts.recurring_payments.frequencies.#{object.frequency}")
  end

  def amount
    h.get_number_to_currency(object.amount, unit(object.from_account))
  end

  def unit(account)
    account.decorate.unit
  end
end
