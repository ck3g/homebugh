class GroupChartData
  def initialize(chart_data)
    @chart_data = Hash(chart_data)
  end

  def group_smallest_categories
    categories = categories!
    categories << [:other, rest] unless rest.zero?

    categories.each_with_object({}) do |(category, sum), grouped|
      grouped[category] = sum
    end
  end

  private

  attr_reader :chart_data

  NONGROUPING_CATEGORIES_COUNT = 5

  def sorted_values
    @sorted_values ||= chart_data.sort_by { |_, value| value }.reverse
  end

  def categories!
    sorted_values.shift(NONGROUPING_CATEGORIES_COUNT)
  end

  def rest
    @rest ||= sorted_values.inject(0) { |total, (_, value)| total + value }
  end
end
