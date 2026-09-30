class TransactionDecorator < Draper::Decorator
  delegate_all

  def amount
    h.get_number_to_currency object.summ, unit
  end

  def signed_amount
    h.signed_money object.summ, unit, income: object.income?
  end

  # Confirm text for rolling back: names the transaction and the balance the
  # account ends up with (AccountBalance.reverse undoes the original change)
  def rollback_confirmation
    sign = object.income? ? "" : "\u2212"
    balance_after = object.account.funds + (object.income? ? -object.summ : object.summ)

    I18n.t('parts.transactions.rollback_confirm',
           amount: "#{sign}#{h.get_number_to_currency(object.summ, unit)}",
           category: category_name,
           account: object.account_name,
           balance: h.get_number_to_currency(balance_after, unit))
  end

  def created_on
    I18n.l(object.created_at.to_date, format: :long)
  end

  def unit
    object.account.decorate.unit
  end

  def category_name
    if object.category
      object.category_name
    else
      t('parts.transactions.no_category')
    end
  end
end
