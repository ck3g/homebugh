// Chart.js helper functions for HomeBugh statistics
var Charts = {
  // Default colors for HomeBugh theme
  colors: {
    primary: '#5cb85c',
    success: '#5cb85c',
    info: '#5bc0de',
    warning: '#f0ad4e',
    danger: '#d9534f',
    income: '#28a745',
    spending: '#dc3545',
    palette: [
      '#5cb85c',   // Light green
      '#5bc0de',   // Light blue
      '#f0ad4e',   // Orange
      '#d9534f',   // Red
      '#9b59b6',   // Purple
      '#e67e22',   // Dark orange
      '#1abc9c',   // Teal
      '#34495e',   // Dark blue-gray
      '#95a5a6',   // Gray
      '#3498db',   // Blue
      '#e74c3c',   // Bright red
      '#f39c12',   // Yellow-orange
      '#ff1744',   // Pink red
      '#8e44ad',   // Dark purple
      '#16a085',   // Dark teal
      '#795548',   // Brown
      '#c0392b',   // Dark red
      '#d35400',   // Dark orange-red
      '#7f8c8d',   // Blue-gray
      '#2c3e50',   // Very dark blue
      '#e91e63',   // Pink
      '#ff9800',   // Amber
      '#607d8b',   // Blue-gray
      '#ffeb3b',   // Yellow
      '#ff5722',   // Deep orange
      '#673ab7',   // Deep purple
      '#2196f3',   // Material blue
      '#ff6f00',   // Material orange
      '#9c27b0',   // Material purple
      '#00bcd4'    // Material cyan
    ]
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
        },
        x: {
          categoryPercentage: 0.8,
          barPercentage: options && options.barWidth ? Math.min(options.barWidth / 100, 1) : 0.6
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

  // Create a stacked bar chart
  createStackedBarChart: function(canvasId, data, options) {
    var ctx = document.getElementById(canvasId).getContext('2d');
    var defaultOptions = {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y',
      scales: {
        x: {
          stacked: true,
          beginAtZero: true,
          ticks: {
            callback: function(value) {
              return value.toLocaleString();
            }
          }
        },
        y: {
          stacked: true,
          categoryPercentage: 0.4,
          barPercentage: 0.8
        }
      },
      plugins: {
        legend: {
          position: 'top',
          align: 'center',
          labels: {
            boxWidth: 12,
            font: {
              size: 12
            }
          }
        },
        tooltip: {
          mode: 'point',
          intersect: true,
          position: 'average',
          yAlign: 'bottom',
          callbacks: {
            label: function(context) {
              var label = context.dataset.label || '';
              if (label) {
                label += ': ';
              }
              label += context.parsed.x.toLocaleString();
              return label;
            },
            title: function(context) {
              return '';
            }
          }
        }
      },
      interaction: {
        mode: 'point',
        intersect: true
      }
    };

    var chartOptions = Object.assign({}, defaultOptions, options || {});
    
    return new Chart(ctx, {
      type: 'bar',
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