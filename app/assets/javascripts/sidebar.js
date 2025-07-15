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
    $('.dashboard-sidebar .nav a[data-toggle="tooltip"]').each(function() {
      $(this).tooltip('destroy'); // Clean up any existing tooltips

      if ($('.dashboard-sidebar').hasClass('collapsed')) {
        $(this).tooltip({
          container: 'body',
          trigger: 'manual',
          placement: 'right',
          html: false,
          animation: true
        });

        // Set up manual hover events
        $(this).hover(
          function() {
            $(this).tooltip('show');
          },
          function() {
            $(this).tooltip('hide');
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

  // Mobile sidebar toggle functionality
  $('.sidebar-toggle').on('click', function(e) {
    e.preventDefault();
    $('.dashboard-sidebar').toggleClass('show');
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

  // Close sidebar when clicking outside on mobile
  $(document).on('click', function(e) {
    if ($(window).width() <= 768) {
      if (!$(e.target).closest('.dashboard-sidebar, .sidebar-toggle').length) {
        $('.dashboard-sidebar').removeClass('show');
      }
    }
  });

  // Handle window resize
  $(window).on('resize', function() {
    if ($(window).width() > 768) {
      $('.dashboard-sidebar').removeClass('show');
    }
  });
});
