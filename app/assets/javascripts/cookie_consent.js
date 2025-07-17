jQuery(window).on('load', function(){
  new CookieConsent().check();
});

class CookieConsent {
  constructor () {
    $('#cookie-consent-button-ok').off('click').on('click', function() {
      Cookies.set('cookie_consent_accepted', true, { expires: 36500 });
    });
  }

  check() {
    const isAccepted = Cookies.get('cookie_consent_accepted');

    if(!isAccepted) {
      const modal = new bootstrap.Modal(document.getElementById('cookie-consent-modal'));
      modal.show();
    }
  }
}

