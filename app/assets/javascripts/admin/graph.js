/*jshint esversion: 6 */
window.AdminGraph = (function() {
  var graphData;
  var ITEM_PER_SECOND = 15;
  var code;
  var created_at;
  var data_window;
  var data_window_start, data_window_end;
  var periodogramGraph;

  var getValue = (x)=> (x == 'NaN' ? 0 : parseFloat(x));

  var init = function(options) {
    var graph;
    code = options.code;
    created_at = options.created_at;
    graphData = options.data.split("\n").map((x) => x.split(" "));
    data_window_start = options.data_window_start;
    data_window_end = options.data_window_end;
    data_window = typeof options.data_window_start === 'number';

    graphData = graphData.map((item) => [getValue(item[0]), getValue(item[1])]);
    graphOptions = {
      drawPoints: true,
      showRoller: true,
      labels: ['Time', 'Breath'],
      showRangeSelector: true,
      legend: 'always',
      zoomCallback: function(minDate, maxDate, yRange) {
        data_window_start = minDate;
        data_window_end = maxDate;
        var periodogramData = calculatePeriodogram();
        periodogramGraph.updateOptions( { 'file': periodogramData } );
      },
    };
    if (data_window) {
      graphOptions.dateWindow = [data_window_start, data_window_end];
    }
    graph = new Dygraph(document.getElementById("graph"),
      graphData, graphOptions);
    initDownloadButton();
    showPeriodogram();
  };

  var saveToFile = function(data, fileName, type) {
    type = type || 'application/octect-stream';
    let a = document.createElement("a");
    let url = URL.createObjectURL(new Blob([data], {type: type}));
    a.href = url;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    setTimeout(function() {
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
    }, 0);
  };

  var selectedGraphData = function() {
    var data = graphData;
    if (data_window) {
      data = graphData.filter(function(item) {
        return item[0] >= data_window_start && item[0] <= data_window_end;
      });
    }
    return data;
  };

  var initDownloadButton = function () {
    var el = document.getElementById("download-button");
    el.addEventListener('click', function() {
      var fileName = code + '-' + created_at.substring(0,19).replace(/:/g, '-') + '.csv';
      var data = selectedGraphData().map((x) =>  x[0] + ',' + x[1]).join("\n");
      saveToFile(data, fileName, 'text/plain');
    });
  };

  var calculatePeriodogram = function() {
    var signal = selectedGraphData().map((x) => x[1]);
    var periodogramOptions = {};
    var periodogram = bci.periodogram(signal, ITEM_PER_SECOND, periodogramOptions);
    var data = periodogram.frequencies.map((x, index) => [1/x, periodogram.estimates[index]]);
    data.shift();
    return data;
  };

  var showPeriodogram = function() {
    var data = calculatePeriodogram();
    periodogramGraph = new Dygraph(document.getElementById("periodogram"),
      data,
      {
        drawPoints: true,
        showRoller: true,
        labels: ['Period', 'Stregth'],
        showRangeSelector: true,
        legend: 'always',
      });
  };

  return {
    init: init
  };
})();
