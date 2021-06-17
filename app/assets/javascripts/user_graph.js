/*jshint esversion: 6 */
window.UserGraph = (function() {
  let dataWindowStart;
  let dataWindowEnd;

  const getValue = (x)=> (x == 'NaN' ? 0 : parseFloat(x));

  const saveDataWindow = (options) => {
    const { measurementId, savePath } = options;
    const formData = new FormData();
    formData.append('measurement[data_window_start]', dataWindowStart);
    formData.append('measurement[data_window_end]', dataWindowEnd);
    formData.append('authenticity_token', csrfToken());
    formData.append('format', 'json');
    return fetch(`${savePath}/${measurementId}`, {
      method: 'PATCH',
      body: formData,
      headers: {
        'Accept': 'application/json, text/plain, */*',
      }
    })
    .then(response => response.json());
  };

  const init = function(options) {
    let graph;
    const { data, recordLength, recordDataWindowLength, measurementId, savePath } = options;
    const maxStart = recordLength - recordDataWindowLength;
    document.getElementById('user-graph-container').style.display = 'block';
    graphData = data.map((x) => x.split(" "));

    graphData = graphData.map((item) => [getValue(item[0]), getValue(item[1])]);

    graph = new Dygraph(document.getElementById("graph"),
      graphData,
      {
        drawPoints: true,
        showRoller: true,
        labels: ['Time', 'Breath'],
        legend: 'always',
        dateWindow: [0, recordDataWindowLength],
      });
    const range = document.getElementById('graph-period');
    range.addEventListener('input', (evt) => {
      const value = range.value;
      dataWindowStart = maxStart * (parseFloat(value) / 100);
      dataWindowEnd = dataWindowStart + recordDataWindowLength;
      graph.updateOptions({dateWindow: [dataWindowStart, dataWindowEnd]});
    }, false);
    const saveEl = document.getElementById('save-data-window');
    saveEl.addEventListener('click', () => saveDataWindow({ measurementId, savePath }), false);
  };

  return {
    init: init
  };
})();
