class Stats
  attr_reader :relation, :currency

  def initialize(currency, relation = AggregatedTransaction)
    if currency.is_a? Currency
      @relation = relation.currency(currency.id)
    else
      @relation = relation.none
    end
  end

  def all
    Enumerator.new do |yielder|
      months.each do |month|
        yielder << {
          month => {
            income: @relation.income.month(month).load,
            spending: @relation.spending.month(month).load
          }
        }
      end
    end
  end

  # Get spending data grouped by month and category for stacked bar chart
  def spending_by_month_and_category(months_count = 6)
    result = {}
    
    all.lazy.first(months_count).each do |month_data|
      month_data.each do |month_date, data|
        month_key = I18n.l(month_date.to_date, format: :month_year)
        result[month_key] = {}
        
        # Process spending data for this month
        data[:spending].each do |aggregated_transaction|
          category_name = aggregated_transaction.category.name
          result[month_key][category_name] = aggregated_transaction.amount
        end
      end
    end
    
    result
  end

  # Get income data grouped by month and category for stacked bar chart
  def income_by_month_and_category(months_count = 6)
    result = {}
    
    all.lazy.first(months_count).each do |month_data|
      month_data.each do |month_date, data|
        month_key = I18n.l(month_date.to_date, format: :month_year)
        result[month_key] = {}
        
        # Process income data for this month
        data[:income].each do |aggregated_transaction|
          category_name = aggregated_transaction.category.name
          result[month_key][category_name] = aggregated_transaction.amount
        end
      end
    end
    
    result
  end

  private

  def months
    relation.order(period_started_at: :desc).pluck(:period_started_at).uniq
  end
end
