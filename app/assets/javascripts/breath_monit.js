/*jshint esversion: 6 */
window.BreathMonit = (function() {
  var cable;
  var measurementChannel;
  var DISPLAY_TIME_GAP = 120; /* seconds */
  var ITEM_PER_SECOND = 15;
  var PREFILLED_COUNT = DISPLAY_TIME_GAP * ITEM_PER_SECOND;
  var graphData = [];
  var graphDataFirstTime = true;
  var graph;
  var user_id;
  var receiveStopped = false;

  var fillGraphData = function() {
    graphData = [];
    for (var index = 0; index < PREFILLED_COUNT; index++) {
      graphData.push([index/ITEM_PER_SECOND - DISPLAY_TIME_GAP, 0]);
    }
  };

  var initGraph = function() {
    fillGraphData();
    graph = new Dygraph(document.getElementById("live-graph"),
      graphData,
      {
        drawPoints: true,
        showRoller: true,
        labels: ['Time', 'Breath'],
        showRangeSelector: true,
        legend: 'always'
      });
  };

  var initStopButton = function () {
    var el = document.getElementById("stop-button");
    el.addEventListener('click', function() {
      var stopped = el.getAttribute('data-stopped');
      if (stopped == 'true') {
        el.setAttribute('data-stopped', 'false');
        el.innerText = 'Stop';
        fillGraphData();
        receiveStopped = false;
      } else {
        el.setAttribute('data-stopped', 'true');
        el.innerText = 'Start';
        receiveStopped = true;
      }
    });
  };

  var initDownloadButton = function () {
    var el = document.getElementById("download-button");
    el.addEventListener('click', function() {
      var fileName = 'breath-monit-' + new Date().toISOString().substring(0,19).replace(/:/g, '-') + '.csv';
      var data = graphData.map((x) => x[0] + ',' + x[1]).join("\n");
      saveToFile(data, fileName, 'text/plain');
    });
  };

  var initReceiver = function(options) {
    user_id = options.user_id;
    cable = ActionCable.createConsumer();
    measurementChannel = cable.subscriptions.create(
      { channel: "MeasurementChannel", id: user_id },
      {
        received: function (data) {
          if (receiveStopped) return;
          if (graph) {
            if (graphDataFirstTime) {
              graphDataFirstTime = false;
            }
            graphData.push([data.m.t, data.m.c]);
            graphData.shift();
            graph.updateOptions( { 'file': graphData } );
          }
        }
      }
    );
    initGraph();
    initStopButton();
    initDownloadButton();
  };

  var initSender = function(options) {
    user_id = options.user_id;
    cable = ActionCable.createConsumer();
    measurementChannel = cable.subscriptions.create(
      { channel: "MeasurementChannel", id: user_id },
      {}
    );
    if (options.presence_path) {
      var update_presence = function() {
        fetch(options.presence_path,
        {
          credentials: 'same-origin'
        });
      };
      update_presence();
      // run it every 30 seconds
      setInterval(update_presence, 30000);
    }
  };

  var send = function(data) {
    measurementChannel.send({ id: user_id, m: data });
  };

  var watch = function(options) {
    document.getElementById("users-present-table").style.display = 'none';
    document.getElementById("live-data").style.display = 'block';
    initReceiver({user_id: options.user_id});
  };

  return {
    initSender: initSender,
    send: send,
    watch: watch,
  };
})();


