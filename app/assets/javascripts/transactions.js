jQuery(function() {
  $('.best_in_place').best_in_place();
  return $('.best_in_place').bind("ajax:success", function() {
    return $(this).closest('tr').effect('highlight', 'slow');
  });
});
