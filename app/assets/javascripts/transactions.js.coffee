

jQuery ->
  $('.best_in_place').best_in_place()
  $('.best_in_place').bind "ajax:success", () ->
    $(this).closest('tr').effect('highlight', 'slow')
