$(document).ready(function() {
  // Check if sidebar should be collapsed from localStorage
  var sidebarCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';

  // Apply saved state WITHOUT animation on page load
  if (sidebarCollapsed) {
    $('.dashboard-sidebar').addClass('collapsed');
    $('.dashboard-content').addClass('sidebar-collapsed');
  }

  // Initialize tooltips - only show when sidebar is collapsed
  function initTooltips() {
    $('.dashboard-sidebar .nav a[data-bs-toggle="tooltip"]').each(function() {
      // Remove any existing Bootstrap 5 tooltips
      var existingTooltip = bootstrap.Tooltip.getInstance(this);
      if (existingTooltip) {
        existingTooltip.dispose();
      }

      // Icon-only collapsed sidebar exists on desktop only; no hover tooltips on touch
      if ($('.dashboard-sidebar').hasClass('collapsed') && !window.matchMedia('(max-width: 767.98px)').matches) {
        // Create new Bootstrap 5 tooltip
        var tooltip = new bootstrap.Tooltip(this, {
          container: 'body',
          trigger: 'manual',
          placement: 'right'
        });

        // Set up manual hover events
        $(this).hover(
          function() {
            tooltip.show();
          },
          function() {
            tooltip.hide();
          }
        );
      }
    });
  }

  // Add animation classes after a short delay to prevent initial animation
  setTimeout(function() {
    $('.dashboard-sidebar').addClass('animate');
    $('.dashboard-content').addClass('animate');

    // Initialize tooltips after animations are ready
    initTooltips();
  }, 100);

  // Mobile sidebar (drawer) - matches Bootstrap's md breakpoint
  var mobileQuery = window.matchMedia('(max-width: 767.98px)');

  function setMobileSidebar(open) {
    $('.dashboard-sidebar').toggleClass('show', open);
    $('body').toggleClass('sidebar-open', open);
    $('.sidebar-toggle').attr('aria-expanded', open ? 'true' : 'false');
  }

  $('.sidebar-toggle').on('click', function(e) {
    e.preventDefault();
    setMobileSidebar(!$('.dashboard-sidebar').hasClass('show'));
  });

  $('.sidebar-backdrop').on('click', function() {
    setMobileSidebar(false);
  });

  $(document).on('keydown', function(e) {
    if (e.key === 'Escape' && $('.dashboard-sidebar').hasClass('show')) {
      setMobileSidebar(false);
      $('.sidebar-toggle').trigger('focus');
    }
  });

  // Desktop sidebar collapse functionality
  $('.sidebar-collapse-btn').on('click', function(e) {
    e.preventDefault();
    var isCollapsed = $('.dashboard-sidebar').hasClass('collapsed');

    $('.dashboard-sidebar').toggleClass('collapsed');
    $('.dashboard-content').toggleClass('sidebar-collapsed');

    // Save state to localStorage
    localStorage.setItem('sidebarCollapsed', !isCollapsed);

    // Reinitialize tooltips for the new state
    initTooltips();
  });

  // Leaving the phone layout closes the drawer
  mobileQuery.addEventListener('change', function(e) {
    if (!e.matches) {
      setMobileSidebar(false);
    }
  });
});
