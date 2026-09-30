# Net amount (income minus expenses) per day and currency for the days that
# appear on one page of transactions. Sums the whole day, so a day split
# across two pages still shows its full total.
class DailyTransactionTotals
  Total = Struct.new(:currency, :amount) do
    def income?
      amount >= 0
    end
  end

  # scope: the filtered transactions relation the list uses (before paging)
  # transactions: the records on the current page
  def initialize(scope, transactions)
    @scope = scope
    @days = transactions.map { |t| t.created_at.to_date }.uniq
  end

  # { Date => [Total, ...] }, currencies in a stable order
  def by_day
    return {} if @days.empty?

    @by_day ||= begin
      currencies = Currency.where(id: sums.keys.map(&:second).uniq).index_by(&:id)

      sums.each_with_object(Hash.new { |h, k| h[k] = Hash.new(0) }) do |((day, currency_id, type_id), sum), acc|
        signed = type_id == CategoryType.income ? sum : -sum
        acc[day.to_date][currency_id] += signed
      end.transform_values do |per_currency|
        per_currency.sort.map { |currency_id, amount| Total.new(currencies[currency_id], amount) }
      end
    end
  end

  private

  def sums
    @sums ||= @scope
      .unscope(:order)
      .joins(:account, :category)
      .where(created_at: @days.min.beginning_of_day..@days.max.end_of_day)
      .group(Arel.sql("DATE(transactions.created_at)"), "accounts.currency_id", "categories.category_type_id")
      .sum(:summ)
  end
end
