class Statistics
  def initialize(currency_id, user_id, date_from, date_to)
    @currency_id = currency_id
    @user_id = user_id
    @date_from = date_from
    @date_to = date_to
    @data = { 1 => nil, 2 => nil }
  end

  def total_income
    get_sum CategoryType.income
  end

  def total_spending
    get_sum CategoryType.spending
  end

  def title
    date_from = I18n.l(@date_from, format: :month_year)
    date_to = I18n.l(@date_from, format: :month_year)

    title = "#{date_from} - #{date_to}"
    if @date_from.year == @date_to.year && @date_from.month == @date_to.month
      title = "#{@date_from.day}-#{@date_to.day} #{date_from}"
    end
    title
  end

  def get_income_categories
    get_categories CategoryType.income
  end

  def get_spending_categories
    get_categories CategoryType.spending
  end

  private

  def get_data(type_id)
    if @data[type_id].nil?
      @data[type_id] = transactions_data(type_id)
    end

    @data[type_id]
  end

  def get_sum(type_id)
    get_data(type_id).sum(:summ)
  end

  def get_categories(type_id)
    categories_data = get_data(type_id).group("transactions.category_id")
    sum_by_category = categories_data.sum(:summ)
    categories = Array.new
    categories_data.each do |data|
      categories << { name: data.category.name, sum: sum_by_category[data.category_id] }
    end

    categories
  end

  private
  attr_reader :currency_id, :user_id

  def transactions_data(type_id)
    Transaction.
      category_type(type_id).
      currency(currency_id).
      created_between(@date_from, @date_to + 23.hours + 59.minutes).
      where("transactions.user_id = ?", user_id)
  end
end
