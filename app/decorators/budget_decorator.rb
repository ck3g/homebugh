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

  def expenses_color_class
    if expenses_percentage < 75
      "success"
    elsif expenses_percentage >= 100
      "danger"
    else
      "warning"
    end
  end

  private

  def expenses_percentage
    @pecentage ||= object.expenses / (object.limit / 100)
  end
end
