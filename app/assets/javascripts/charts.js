// Chart.js helper functions for HomeBugh statistics
var Charts = {
  // Default colors for HomeBugh theme
  colors: {
    primary: '#47a447',
    success: '#5cb85c',
    info: '#5bc0de',
    warning: '#f0ad4e',
    danger: '#d9534f',
    income: '#47a447',
    spending: '#d9534f',
    palette: ['#47a447', '#5cb85c', '#5bc0de', '#f0ad4e', '#d9534f', '#9b59b6', '#e67e22', '#1abc9c', '#34495e', '#95a5a6']
  },

  // Create a pie chart
  createPieChart: function(canvasId, data, options) {
    var ctx = document.getElementById(canvasId).getContext('2d');
    var defaultOptions = {
      responsive: true,
      maintainAspectRatio: true,
      aspectRatio: 1,
      plugins: {
        legend: {
          position: 'bottom',
          labels: {
            padding: 15,
            usePointStyle: true,
            font: {
              size: 12
            }
          }
        }
      }
    };

    var chartOptions = Object.assign({}, defaultOptions, options || {});
    
    return new Chart(ctx, {
      type: 'pie',
      data: data,
      options: chartOptions
    });
  },

  // Create a bar chart
  createBarChart: function(canvasId, data, options) {
    var ctx = document.getElementById(canvasId).getContext('2d');
    var defaultOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            callback: function(value) {
              return value.toLocaleString();
            }
          }
        }
      }
    };

    var chartOptions = Object.assign({}, defaultOptions, options || {});
    
    return new Chart(ctx, {
      type: 'bar',
      data: data,
      options: chartOptions
    });
  },

  // Create a line chart
  createLineChart: function(canvasId, data, options) {
    var ctx = document.getElementById(canvasId).getContext('2d');
    var defaultOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top'
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            callback: function(value) {
              return value.toLocaleString();
            }
          }
        }
      }
    };

    var chartOptions = Object.assign({}, defaultOptions, options || {});
    
    return new Chart(ctx, {
      type: 'line',
      data: data,
      options: chartOptions
    });
  },

  // Convert object data to Chart.js format
  convertToChartData: function(data, colors) {
    var labels = Object.keys(data);
    var values = Object.values(data);
    var backgroundColors = colors || this.colors.palette.slice(0, labels.length);

    return {
      labels: labels,
      datasets: [{
        data: values,
        backgroundColor: backgroundColors,
        borderColor: backgroundColors,
        borderWidth: 1
      }]
    };
  },

  // Format currency for display
  formatCurrency: function(value, currency) {
    return value.toLocaleString() + ' ' + (currency || '');
  }
};

// Initialize charts when DOM is ready
$(document).ready(function() {
  // Chart initialization will be handled by individual chart functions
});