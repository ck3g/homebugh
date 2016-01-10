class Statistic
  def self.current_month_stats(currency_id, user_id)
    current_date = DateTime.current.beginning_of_month.to_date

    month_stats = Statistics.new(currency_id, user_id, current_date.beginning_of_month, current_date.end_of_month)
    income_chart_data = {}
    month_stats.get_income_categories.each do |category|
      income_chart_data[category[:name]] = category[:sum]
    end
    spending_chart_data = {}
    month_stats.get_spending_categories.each do |category|
      spending_chart_data[category[:name]] = category[:sum]
    end
    [{
      title: month_stats.title,
      income: month_stats.total_income,
      income_categories: month_stats.get_income_categories,
      spending: month_stats.total_spending,
      spending_categories: month_stats.get_spending_categories,
      income_chart_data: income_chart_data,
      spending_chart_data: spending_chart_data
    }]
  end
end
