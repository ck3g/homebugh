
jQuery ->
  $(".pagination").hide()
  if $(".pagination").length
    $(window).scroll ->
      url = $(".pagination .next a").attr("href")
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 200
        $('.preloader').show()
        $.getScript(url)

    $(window).scroll()

  $canvas = $('#canvas')
  if $canvas.length is 1
    labels = []
    incomeData = []
    spendingData = []

    $('input.chart-label').each (index) ->
      $this = $(this)
      labels.push $this.val()
      incomeData.push $this.data('income')
      spendingData.push $this.data('spending')

    data = {
      labels : labels,
      datasets : [
        {
          fillColor : "rgba(220,220,220,0.5)",
          strokeColor : "rgba(220,220,220,1)",
          pointColor : "rgba(220,220,220,1)",
          pointStrokeColor : "#fff",
          data : spendingData
        },
        {
          fillColor : "rgba(151,187,205,0.5)",
          strokeColor : "rgba(151,187,205,1)",
          pointColor : "rgba(151,187,205,1)",
          pointStrokeColor : "#fff",
          data : incomeData
        }
      ]
    }

    chart = new Chart($canvas.get(0).getContext("2d"))

    hash = window.location.hash
    if hash is '#bar'
      chart.Bar(data)
    else
      chart.Line(data)

    $(document).on 'click', 'a.js-line-chart', (e) ->
      e.preventDefault()
      chart.Line(data)

    $(document).on 'click', 'a.js-bar-chart', (e) ->
      e.preventDefault()
      chart.Bar(data)

