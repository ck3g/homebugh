class TransactionDecorator < Draper::Decorator
  delegate_all

  def amount
    h.get_number_to_currency object.summ, unit
  end

  def signed_amount
    h.signed_money object.summ, unit, income: object.income?
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
