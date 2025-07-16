module ChartsHelper
  # Create a pie chart with Chart.js
  def chartjs_pie_chart(data, options = {})
    canvas_id = "chart-#{SecureRandom.hex(4)}"
    chart_data = prepare_chart_data(data, options[:colors])
    
    content_tag(:div, class: "chart-container") do
      canvas_tag(canvas_id, options[:height] || 300) +
      javascript_tag(pie_chart_script(canvas_id, chart_data, options))
    end
  end

  # Create a bar chart with Chart.js
  def chartjs_bar_chart(data, options = {})
    canvas_id = "chart-#{SecureRandom.hex(4)}"
    chart_data = prepare_chart_data(data, options[:colors])
    
    content_tag(:div, class: "chart-container") do
      canvas_tag(canvas_id, options[:height] || 300) +
      javascript_tag(bar_chart_script(canvas_id, chart_data, options))
    end
  end

  # Create a line chart with Chart.js
  def chartjs_line_chart(data, options = {})
    canvas_id = "chart-#{SecureRandom.hex(4)}"
    chart_data = prepare_chart_data(data, options[:colors])
    
    content_tag(:div, class: "chart-container") do
      canvas_tag(canvas_id, options[:height] || 300) +
      javascript_tag(line_chart_script(canvas_id, chart_data, options))
    end
  end

  # Create a stacked bar chart with Chart.js
  def chartjs_stacked_bar_chart(data, options = {})
    canvas_id = "chart-#{SecureRandom.hex(4)}"
    chart_data = prepare_stacked_chart_data(data, options[:colors])
    
    content_tag(:div, class: "stacked-chart-container") do
      canvas_tag(canvas_id, options[:height] || 120) +
      javascript_tag(stacked_bar_chart_script(canvas_id, chart_data, options))
    end
  end

  private

  def canvas_tag(canvas_id, height)
    content_tag(:canvas, "", id: canvas_id, style: "width: 100%; height: #{height}px;")
  end

  def prepare_chart_data(data, colors = nil)
    if data.is_a?(Hash)
      {
        labels: data.keys,
        data: data.values,
        colors: colors || default_colors(data.keys.length)
      }
    else
      data
    end
  end

  def default_colors(count)
    base_colors = [
      '#5cb85c',   # Light green
      '#5bc0de',   # Light blue
      '#f0ad4e',   # Orange
      '#d9534f',   # Red
      '#9b59b6',   # Purple
      '#e67e22',   # Dark orange
      '#1abc9c',   # Teal
      '#34495e',   # Dark blue-gray
      '#95a5a6',   # Gray
      '#3498db',   # Blue
      '#e74c3c',   # Bright red
      '#f39c12',   # Yellow-orange
      '#ff1744',   # Pink red
      '#8e44ad',   # Dark purple
      '#16a085',   # Dark teal
      '#795548',   # Brown
      '#c0392b',   # Dark red
      '#d35400',   # Dark orange-red
      '#7f8c8d',   # Blue-gray
      '#2c3e50',   # Very dark blue
      '#e91e63',   # Pink
      '#ff9800',   # Amber
      '#607d8b',   # Blue-gray
      '#ffeb3b',   # Yellow
      '#ff5722',   # Deep orange
      '#673ab7',   # Deep purple
      '#2196f3',   # Material blue
      '#ff6f00',   # Material orange
      '#9c27b0',   # Material purple
      '#00bcd4'    # Material cyan
    ]
    base_colors.cycle.take(count)
  end

  def pie_chart_script(canvas_id, data, options)
    %{
      (function() {
        var chartData = #{chart_data_to_json(data)};
        Charts.createPieChart('#{canvas_id}', chartData, #{options.to_json});
      })();
    }.html_safe
  end

  def bar_chart_script(canvas_id, data, options)
    %{
      (function() {
        var chartData = #{chart_data_to_json(data)};
        Charts.createBarChart('#{canvas_id}', chartData, #{options.to_json});
      })();
    }.html_safe
  end

  def line_chart_script(canvas_id, data, options)
    %{
      (function() {
        var chartData = #{chart_data_to_json(data)};
        Charts.createLineChart('#{canvas_id}', chartData, #{options.to_json});
      })();
    }.html_safe
  end

  def stacked_bar_chart_script(canvas_id, data, options)
    %{
      (function() {
        var chartData = #{data.to_json};
        Charts.createStackedBarChart('#{canvas_id}', chartData, #{options.to_json});
      })();
    }.html_safe
  end

  def chart_data_to_json(data)
    {
      labels: data[:labels],
      datasets: [{
        data: data[:data],
        backgroundColor: data[:colors],
        borderColor: data[:colors],
        borderWidth: 1
      }]
    }.to_json.html_safe
  end

  # Group small spending categories into "Other" category
  def group_small_spending_categories(spending_data, threshold_percentage = 5)
    return spending_data if spending_data.empty?
    
    total_spending = spending_data.values.sum
    threshold_amount = total_spending * (threshold_percentage / 100.0)
    
    large_categories = {}
    small_categories_total = 0
    
    spending_data.each do |category, amount|
      if amount >= threshold_amount
        large_categories[category] = amount
      else
        small_categories_total += amount
      end
    end
    
    # Add "Other" category if there are small categories
    if small_categories_total > 0
      large_categories["Other"] = small_categories_total
    end
    
    large_categories
  end

  # Prepare data for stacked bar chart
  def prepare_stacked_chart_data(data, colors = nil)
    return { labels: [], datasets: [] } if data.empty?
    
    # Get all unique categories across all months
    all_categories = data.values.flat_map(&:keys).uniq
    
    # Get month labels (keys)
    month_labels = data.keys
    
    # Create datasets for each category
    datasets = all_categories.map.with_index do |category, index|
      category_data = month_labels.map { |month| data[month][category] || 0 }
      color = colors ? colors[index % colors.length] : default_colors(all_categories.length)[index]
      
      {
        label: category,
        data: category_data,
        backgroundColor: color,
        borderColor: color,
        borderWidth: 1
      }
    end
    
    {
      labels: month_labels,
      datasets: datasets
    }
  end
end