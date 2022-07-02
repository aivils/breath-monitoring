/*jshint esversion: 6 */
window.BreathMonit = (function() {
  var cable;
  var measurementChannel;
  var displayTimeGap = 30; /* seconds */
  var ITEM_PER_SECOND = 15;
  var allData = [];
  var graphData = [];
  var graphDataFirstTime = true;
  var graph;
  var user_id;
  var user_code;
  var receiveStopped = false;
  var periodogram;
  var periodogramTime;
  var UPDATE_PERIODOGRAM = 0.5; /* every x seconds */

  var calculatePeriodogram = function() {
    var signal = graphData.map((x) => x[1]);
    var periodogramOptions = {};
    var periodogram = bci.periodogram(signal, ITEM_PER_SECOND, periodogramOptions);
    var data = periodogram.frequencies.map((x, index) => [1/x, periodogram.estimates[index]]);
    data.shift();
    return data;
  };

  var showPeriodogram = function() {
    var data = calculatePeriodogram();
    periodogram = new Dygraph(document.getElementById("periodogram-graph"),
      data,
      {
        drawPoints: true,
        showRoller: true,
        labels: ['Period', 'Stregth'],
        showRangeSelector: true,
        legend: 'always',
      });
  };

  var fillGraphData = function() {
    allData = [];
    graphData = [];
    displayTimeGap = parseInt(document.getElementById(`user_display_time_${user_id}`).value);
    var prefilledCount = displayTimeGap * ITEM_PER_SECOND;
    for (var index = 0; index < prefilledCount; index++) {
      graphData.push([index/ITEM_PER_SECOND - displayTimeGap, 0]);
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
        legend: 'always',
        axes: {
          x: {
            axisLabelFormatter: function(x, gran, opts) {
              if (x < 0) {
                x = x + displayTimeGap;
              }
                return x;
            }
          }
        }
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
      var date = new Date().toISOString().substring(0,19).replace(/:/g, '-');
      var fileName = `breath-monit-${user_code}-${date}.csv`;
      var data = allData.map((x) => x[0] + ',' + x[1]).join("\n");
      saveToFile(data, fileName, 'text/plain');
    });
  };

  var initReceiver = function(options) {
    user_id = options.user_id;
    user_code = options.user_code;
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
            var dataTime = data.m.t;
            graphData.push([dataTime, data.m.c]);
            graphData.shift();
            allData.push([dataTime, data.m.c]);
            graph.updateOptions( { 'file': graphData } );
            if (data.m.t >= displayTimeGap/2 && !periodogramTime) {
              periodogramTime = dataTime;
              showPeriodogram();
            }
            if (periodogramTime && (dataTime - periodogramTime) >= UPDATE_PERIODOGRAM) {
              periodogramTime = dataTime;
              periodogram.updateOptions({ 'file': calculatePeriodogram() });
            }
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
    initReceiver(options);
  };

  return {
    initSender: initSender,
    send: send,
    watch: watch,
  };
})();


