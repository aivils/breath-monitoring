window.BreathMonit = (function() {
  var cable;
  var measurementChannel;
  var graphData = [
    [new Date(), 5000]
  ];
  var graphDataFirstTime = true;
  var graph;

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

  var init = function() {
    cable = ActionCable.createConsumer();
    measurementChannel = cable.subscriptions.create(
      { channel: "MeasurementChannel", room: "1" },
      {
        received: function (data) {
          if (graphDataFirstTime) {
            graphDataFirstTime = false;
            graphData = [];
          }
          graphData.push([new Date(data.measurement.frameTime), data.measurement.count]);
          if (graph) {
            graph.updateOptions( { 'file': graphData } );
          }
        }
      }
    );
   };

  var send = function(data) {
    measurementChannel.send({ measurement: data });
  };

  return {
    init: init,
    send: send,
    initGraph: initGraph
  };
})();


BreathMonit.init();


