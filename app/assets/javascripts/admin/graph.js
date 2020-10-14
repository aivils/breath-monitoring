/*jshint esversion: 6 */
window.AdminGraph = (function() {
  var graphData;
  var init = function(rawGraphData) {
    var graph;
    graphData = rawGraphData.split("\n").map((x) => x.split(" "));

    graphData = graphData.map((y) => [new Date(parseInt(y[0])), parseFloat(y[1])]);

    graph = new Dygraph(document.getElementById("graph"),
      graphData,
      {
        drawPoints: true,
        showRoller: true,
        labels: ['Time', 'Breath'],
        showRangeSelector: true,
        legend: 'always'
      });
    initDownloadButton();
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

  var initDownloadButton = function () {
    var el = document.getElementById("download-button");
    el.addEventListener('click', function() {
      var fileName = 'breath-monit-' + new Date().toISOString().substring(0,19).replace(/:/g, '-') + '.csv';
      var data = graphData.map((x) =>  x[0] + ',' + x[1]).join("\n");
      saveToFile(data, fileName, 'text/plain');
    });
  };

  return {
    init: init
  };
})();
