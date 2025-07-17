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

  def self.twelve_month_totals(currency, user, current_month_stats, past_months_stats)
    twelve_month_income = 0
    twelve_month_spending = 0
    
    # Sum from current month stats
    current_month_stats.each do |stats|
      twelve_month_income += stats[:income] || 0
      twelve_month_spending += stats[:spending] || 0
    end
    
    # Sum from past months stats (first 11 months)
    past_months_stats.first(11).each do |months|
      months.each do |month, monthly_data|
        twelve_month_income += monthly_data[:income].pluck(:amount).inject(:+) || 0
        twelve_month_spending += monthly_data[:spending].pluck(:amount).inject(:+) || 0
      end
    end
    
    twelve_month_net_balance = twelve_month_income - twelve_month_spending
    
    {
      income: twelve_month_income,
      spending: twelve_month_spending,
      net_balance: twelve_month_net_balance
    }
  end
end
