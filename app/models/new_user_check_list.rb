class NewUserCheckList
  def initialize(user:, locale: :en)
    @user = user
  end

  def all_hints_done?
    account_hint_done? &&
      income_category_hint_done? &&
      spending_category_hint_done? &&
      transaction_hint_done?
  end

  def account_hint_done?
    user.accounts.exists?
  end

  def income_category_hint_done?
    user.categories.income.exists?
  end

  def spending_category_hint_done?
    user.categories.spending.exists?
  end

  def transaction_hint_done?
    user.transactions.exists?
  end

  private

  attr_reader :user
end
