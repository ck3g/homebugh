class BudgetDecorator < Draper::Decorator
  delegate_all

  def current_expenses(date: Date.current)
    [
      h.get_number_to_currency(object.expenses(date: date), "").strip,
      "/",
      h.get_number_to_currency(object.limit, currency_unit)
    ].join(" ")
  end

  def currency_unit
    object.currency.unit.presence || object.currency.name
  end

  def expenses_color_class(date: Date.current)
    if expenses_percentage(date: date) < 75
      "success"
    elsif expenses_percentage(date: date) >= 100
      "danger"
    else
      "warning"
    end
  end

  private

  def expenses_percentage(date: Date.current)
    @pecentage ||= object.expenses(date: date) / (object.limit / 100)
  end
end
