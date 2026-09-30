// Shows the cookie consent bar until the visitor accepts it.
$(function() {
  var $bar = $('#cookie-consent');
  if (!$bar.length || Cookies.get('cookie_consent_accepted')) return;

  $bar.prop('hidden', false);

  $('#cookie-consent-button-ok').on('click', function() {
    Cookies.set('cookie_consent_accepted', true, { expires: 36500 });
    $bar.prop('hidden', true);
  });
});
