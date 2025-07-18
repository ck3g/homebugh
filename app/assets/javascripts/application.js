// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//= require jquery
//= require jquery_ujs
//= require jquery-ui
// Bootstrap 5 loaded via CDN - removed require bootstrap
//= require jquery.purr
//= require best_in_place
//= require select2
//= require select2_locale_ru
//= require js.cookie
// Chart.js loaded via CDN in layout
//= require_self
//= require react
//= require react_ujs
//= require components
//= require_tree .


jQuery(function() {
  $("[data-select-2]").select2();
  
  // Bootstrap 5 should handle dropdowns automatically
  console.log('Bootstrap version:', typeof bootstrap !== 'undefined' ? 'Bootstrap 5' : 'Bootstrap 3 or not loaded');
  
  // Let Bootstrap handle everything automatically - no manual intervention needed
});
