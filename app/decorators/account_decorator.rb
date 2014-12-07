class AccountDecorator < Draper::Decorator
  def amount
    h.get_number_to_currency object.funds, unit
  end

  def name
    "#{object.name} [#{unit}]"
  end

  def unit
    object.currency_unit.presence || object.currency_name
  end
end
