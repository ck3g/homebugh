class CashFlowDecorator < Draper::Decorator
  delegate_all

  def amount
    h.get_number_to_currency object.amount, unit(object.to_account)
  end

  def initial_amount
    amount = object.initial_amount.presence || object.amount
    h.get_number_to_currency amount, unit(object.from_account)
  end

  def unit(account)
    account.decorate.unit
  end
end
