class GroupChartData
  def initialize(chart_data, nongrouping_categoires_count = 8)
    @chart_data = Hash(chart_data)
    @nongrouping_categoires_count = nongrouping_categoires_count
  end

  def group_smallest_categories
    categories = categories!
    categories << [:other, rest] unless rest.zero?

    categories.each_with_object({}) do |(category, sum), grouped|
      grouped[category] = sum
    end
  end

  private

  attr_reader :chart_data, :nongrouping_categoires_count

  def sorted_values
    @sorted_values ||= chart_data.sort_by { |_, value| value }.reverse
  end

  def categories!
    sorted_values.shift(nongrouping_categoires_count)
  end

  def rest
    @rest ||= sorted_values.inject(0) { |total, (_, value)| total + value }
  end
end
