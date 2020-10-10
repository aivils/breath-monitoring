/*jshint esversion: 6 */
window.BreathMonit = (function() {
  var cable;
  var measurementChannel;
  var graphData = [
    [new Date(), 0]
  ];
  var graphDataFirstTime = true;
  var graph;
  var user_id;
  var receiveStopped = false;

  var initGraph = function() {
    graph = new Dygraph(document.getElementById("live-graph"),
      graphData,
      {
        drawPoints: true,
        showRoller: true,
        valueRange: [0.0, 1.0],
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
        graphData = [];
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
      var headers = "Timestamp, Value\n";
      var data = graphData.map((x) =>  x[0].toISOString() + ',' + x[1]).join("\n");
      saveToFile(headers + data, fileName, 'text/plain');
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
              graphData = [];
            }
            graphData.push([new Date(data.m.t), data.m.c]);
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


