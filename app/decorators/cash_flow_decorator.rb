class CashFlowDecorator < Draper::Decorator
  delegate_all

  def amount
    h.get_number_to_currency object.amount, unit(object.to_account)
  end

  def initial_amount
    amount = object.initial_amount.presence || object.amount
    h.get_number_to_currency amount, unit(object.from_account)
  end

  # Only worth showing when the withdrawal differs from the deposit
  # (a fee, or a transfer between currencies)
  def initial_amount_differs?
    object.initial_amount.present? &&
      (object.initial_amount != object.amount || object.from_account.currency_id != object.to_account.currency_id)
  end

  def unit(account)
    account.decorate.unit
  end
end
