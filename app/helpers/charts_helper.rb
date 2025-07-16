module ChartsHelper
  # Create a pie chart with Chart.js
  def chartjs_pie_chart(data, options = {})
    canvas_id = "chart-#{SecureRandom.hex(4)}"
    chart_data = prepare_chart_data(data)
    
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
    base_colors = ['#47a447', '#5cb85c', '#5bc0de', '#f0ad4e', '#d9534f', '#9b59b6', '#e67e22', '#1abc9c', '#34495e', '#95a5a6']
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
end