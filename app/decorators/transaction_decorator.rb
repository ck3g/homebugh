class TransactionDecorator < Draper::Decorator
  delegate_all

  def amount
    amount = object.income? ? object.summ : -object.summ
    h.get_number_to_currency amount, unit
  end

  def created_on
    I18n.l(object.created_at.to_date, format: :long)
  end

  def unit
    object.account.decorate.unit
  end
end
