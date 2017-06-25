class BudgetDecorator < Draper::Decorator
  delegate_all

  def current_expenses
    [
      h.get_number_to_currency(object.expenses, "").strip,
      "/",
      h.get_number_to_currency(object.limit, currency_unit)
    ].join(" ")
  end

  def currency_unit
    object.currency.unit.presence || object.currency.name
  end
end
