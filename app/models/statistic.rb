class Statistic < ActiveRecord::Base

  def self.stats_by_months(user_id)
    first_date = Transaction.first.created_at.to_date
    today = DateTime.now
    current_date = Date.new(today.year, today.month, 1)

    stats = Array.new
    while current_date >= first_date do
      first_day = Date.new current_date.year, current_date.month, 1
      last_day = Date.new current_date.year, current_date.month, -1
      month_stats = Statistics.new(user_id, first_day, last_day)
      stats_data = {
          title: month_stats.title,
          income: month_stats.total_income,
          income_categories: month_stats.get_income_categories,
          spending: month_stats.total_spending,
          spending_categories: month_stats.get_spending_categories
      }
      stats << stats_data
      current_date -= 1.month
    end

    stats
  end

end
