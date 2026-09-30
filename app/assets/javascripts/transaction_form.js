// Recent-category chips on the new transaction form.
// A chip is a one-tap shortcut for the category select below it; the select
// (select2) stays the source of truth so the form works without this script.
$(function() {
  var $select = $('#transaction_category_id');
  var $chips = $('.category-chip');
  if (!$select.length || !$chips.length) return;

  function syncChips() {
    var value = String($select.val() || '');
    $chips.each(function() {
      var pressed = String($(this).data('category-id')) === value;
      $(this).attr('aria-pressed', pressed ? 'true' : 'false');
    });
  }

  $chips.on('click', function() {
    var id = $(this).data('category-id');
    if ($select.data('select2')) {
      $select.select2('val', id);
    } else {
      $select.val(id);
    }
    $select.trigger('change');
  });

  $select.on('change', syncChips);
  syncChips();
});
