window.BreathMonit = (function() {
  var cable;
  var measurementChannel;
  var graphData = [
    [new Date(), 5000]
  ];
  var graphDataFirstTime = true;
  var graph;
  var user_id;

  var initGraph = function() {
    graph = new Dygraph(document.getElementById("live-data"),
      graphData,
      {
        drawPoints: true,
        showRoller: true,
        valueRange: [0.0, 6000.0],
        labels: ['Time', 'Breath']
      });
  };

  var init = function(options) {
    user_id = options.user_id;
    cable = ActionCable.createConsumer();
    measurementChannel = cable.subscriptions.create(
      { channel: "MeasurementChannel", user_id: user_id },
      {
        received: function (data) {
          if (graph) {
            if (graphDataFirstTime) {
              graphDataFirstTime = false;
              graphData = [];
            }
            graphData.push([new Date(data.measurement.frameTime), data.measurement.count]);
            graph.updateOptions( { 'file': graphData } );
          }
        }
      }
    );
    if (options.graph) {
      initGraph();
    }
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
    measurementChannel.send({ user_id: user_id, measurement: data });
  };

  var watch = function(options) {
    document.getElementById("users-present-table").style.display = 'none';
    init({user_id: options.user_id, graph: true});
  };

  return {
    init: init,
    send: send,
    initGraph: initGraph,
    watch: watch,
  };
})();


