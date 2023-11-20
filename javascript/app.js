var seriesOptions = [],
  seriesCounter = 0,
  names = ['SPY', 'XSW'];

/**
 * Create the chart when all data is loaded
 */
function stockStockChart() {

  Highcharts.stockChart('indexfunds', {
    title: {
      text: 'Series compare by <em>percent</em>'
    },
    subtitle: {
      text: 'Compare the values of the series against the first value in the visible range'
    },

    rangeSelector: {
      selected: 4
    },

    yAxis: {
      labels: {
        formatter: function() {
          return (this.value > 0 ? ' + ' : '') + this.value + '%';
        }
      }
    },

    plotOptions: {
      series: {
        compare: 'percent'
      }
    },

    tooltip: {
      pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.change}%)<br/>',
      changeDecimals: 2,
      valueDecimals: 2
    },

    series: seriesOptions
  });
}

function renderStockChart(data) {
  var name = this.url.match(/(SPY|XSW)/)[0].toUpperCase();
  var i = names.indexOf(name);
  seriesOptions[i] = {
    name: name,
    data: data
  };

  // As we're loading the data asynchronously, we don't know what order it
  // will arrive. So we keep a counter and create the chart when all the data is loaded.
  seriesCounter += 1;

  if (seriesCounter === names.length) {
    stockStockChart();
  }
}




function renderSECChart(activity) {

  // debugger;
  // activity = JSON.parse(activity);
  activity.datasets.forEach(function(dataset, i) {

    // Add X values
    dataset.data = Highcharts.map(dataset.data, function(val, j) {
      return [activity.xData[j], val];
    });

    var chartDiv = document.createElement('div');
    chartDiv.className = 'chart';
    document.getElementById('secform4').appendChild(chartDiv);

    Highcharts.chart(chartDiv, {
      chart: {
        marginLeft: 40, // Keep all charts left aligned
        spacingTop: 20,
        spacingBottom: 20
      },
      title: {
        text: dataset.name,
        align: 'left',
        margin: 0,
        x: 30
      },
      credits: {
        enabled: false
      },
      legend: {
        enabled: false
      },
      xAxis: {
        type: "datetime",
         labels: {
          formatter: function() {
            return Highcharts.dateFormat('%b %Y', this.value);
          }
        }
      },
      yAxis: {
        title: {
          text: null
        }
      },
      tooltip: {
        positioner: function() {
          return {
            // right aligned
            x: this.chart.chartWidth - this.label.width,
            y: 10 // align to title
          };
        },
        borderWidth: 0,
        backgroundColor: 'none',
        pointFormat: '{point.y}',
        headerFormat: '',
        shadow: false,
        style: {
          fontSize: '18px'
        },
        valueDecimals: dataset.valueDecimals
      },
      plotOptions: {
        column: {
          pointPadding: 0.0,
          borderWidth: 0
        }
      },
      series: [{
        data: dataset.data,
        name: dataset.name,
        type: dataset.type,
        color: Highcharts.getOptions().colors[i],
        fillOpacity: 0.3,
        tooltip: {
          valueSuffix: ' ' + dataset.unit
        }
      }]
    });
  });
}


Highcharts.getJSON(
  '/data/XSW.json',
  renderStockChart
);
Highcharts.getJSON(
  '/data/SPY.json',
  renderStockChart
);

Highcharts.getJSON(
  '/data/secform4.json',
  renderSECChart
);