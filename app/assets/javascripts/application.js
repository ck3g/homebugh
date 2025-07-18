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
  
  // Initialize Bootstrap 5 popovers and tooltips
  if (typeof bootstrap !== 'undefined') {
    // Initialize popovers
    const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
    const popoverList = [...popoverTriggerList].map(popoverTriggerEl => {
      return new bootstrap.Popover(popoverTriggerEl);
    });
    
    // Initialize tooltips (excluding sidebar tooltips which are handled separately)
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]:not(.dashboard-sidebar [data-bs-toggle="tooltip"])');
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  }
});
