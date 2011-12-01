class Statistics

  def initialize user_id, date_from, date_to
    @user_id = user_id
    @date_from = date_from
    @date_to = date_to
    @data = {1 => nil, 2 => nil}
  end

  def total_income
    get_sum CategoryType.income
  end

  def total_spending
    get_sum CategoryType.spending
  end

  def title
    date_from = I18n.l(@date_from, :format => :month_year)
    date_to = I18n.l(@date_from, :format => :month_year)

    title = "#{date_from} - #{date_to}"
    title = "#{@date_from.day}-#{@date_to.day} #{date_from}" if @date_from.year == @date_to.year && @date_from.month == @date_to.month
    title
  end

  def get_income_categories
    get_categories CategoryType.income
  end

  def get_spending_categories
    get_categories CategoryType.spending
  end

  #private

  # @param type_id [Fixnum]
  def get_data type_id
    if @data[type_id].nil?
      @data[type_id] = Transaction.includes(:category).where("transactions.user_id = :user_id AND categories.category_type_id = :type_id AND transactions.created_at >= :date_from AND transactions.created_at <= :date_to",
                                          {:user_id => @user_id, :type_id => type_id, :date_from => @date_from, :date_to => (@date_to + 23.hours + 59.minutes)})
    end

    @data[type_id]
  end

  def get_sum type_id
    get_data(type_id).sum(:summ)
  end

  def get_categories type_id
    categories_data = get_data(type_id).group("transactions.category_id")
    sum_by_category = categories_data.sum(:summ)
    categories = Array.new
    categories_data.each do |data|
      categories << {:name => data.category.name, :sum => sum_by_category[data.category_id]}
    end

    categories
  end

end
