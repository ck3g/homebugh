class Statistic

  def self.current_month_stats(user_id)
    current_date = DateTime.current.beginning_of_month.to_date

    month_stats = Statistics.new(user_id, current_date.beginning_of_month, current_date.end_of_month)
    [{
      title: month_stats.title,
      income: month_stats.total_income,
      income_categories: month_stats.get_income_categories,
      spending: month_stats.total_spending,
      spending_categories: month_stats.get_spending_categories
    }]
  end

end
