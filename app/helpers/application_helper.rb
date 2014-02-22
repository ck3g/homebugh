module ApplicationHelper
  def get_number_to_currency number
    number_to_currency number, unit: 'лей', format: '%n %u'
  end

  def accounts_recalculate
    user_id = current_user.id

    account = current_user.accounts.first
    # todo: refactor to sum() method
    incomes = current_user.transactions.includes(:category).where('categories.category_type_id' => CategoryType.income)
    total_income = 0.0
    incomes.each { |income| total_income += income.summ.to_f }

    # todo: refactor to sum() method
    spendings = current_user.transactions.includes(:category).where('categories.category_type_id' => CategoryType.spending)
    total_spending = 0.0
    spendings.each { |spending| total_spending += spending.summ.to_f }

    diff = total_income - total_spending

    account.deposit(diff)
    current_user.transactions.update_all(account_id: account.id)
  end

  def get_total_income(account_id, user_id = nil)
    get_total_by_type(1, account_id, user_id)
  end

  def get_total_spending(account_id, user_id = nil)
    get_total_by_type(2, account_id, user_id)
  end

  def inverse_locale
    is_ru? ? 'en' : 'ru'
  end

  def flash_class(name)
    css_classes = ["alert"]
    css_classes << " alert-error" if name == :alert
    css_classes << " alert-success" if name == :notice
    css_classes.join(" ")
  end

  private
  def is_ru?
    I18n.locale == :ru
  end

  def get_total_by_type(type_id, account_id, user_id = nil)
    user_id ||= current_user.id
    transactions = Transaction.includes(:category).where('categories.category_type_id' => type_id, user_id: user_id, account_id: account_id)
    total_funds = 0
    transactions.each { |transaction| total_funds += transaction.summ.to_f }

    total_funds
  end
end
