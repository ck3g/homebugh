
jQuery ->
  $(".pagination").hide()
  if $(".pagination").length
    $(window).scroll ->
      url = $(".pagination .next a").attr("href")
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 200
        $('.preloader').show()
        $.getScript(url)

    $(window).scroll()
