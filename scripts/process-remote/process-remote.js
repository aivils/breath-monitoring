#!/usr/bin/env node
/*
 * before you run the script
export ANSHEALTH_APIKEY=change-me
*/
const axios = require('axios').default;
const { spawnSync } = require('node:child_process');

const DEFAULT_HOST = 'https://anshealth.stohotel.lv';
const DEFAULT_PATH = '/api/v2/measurements';

const host = process.env.ANSHEALTH_HOST || DEFAULT_HOST;
const apikey = process.env.ANSHEALTH_APIKEY;
const baseURL = `${host}${DEFAULT_PATH}`;

/*
  if singleMeasurementId is defined then this script will read and update
  a single measurement record as many times as necessary
*/
const singleMeasurementId = null;

const api = axios.create({
  baseURL,
});

const readMeasurements = async ({ page }) => {
  const path = singleMeasurementId ? `/${singleMeasurementId}` : '/';
  const result = await api.get(path, { params: { apikey, page } });
  //console.log('result=', JSON.stringify(result.data,null,4));
  return result.data;
};

const processMeasurement = (measurement) => {
  const { id, user_id, code, c19_probability, data_parsed, created_at } = measurement;
  console.debug(`[${id}] process`);
  console.table({ id, user_id, code, c19_probability, created_at });
  const dataCsv = data_parsed.map(i => i.join(', ')).join('\n');
  // console.debug('dataCsv=', dataCsv);
  const dataParsedBuffer = Buffer.from(dataCsv);
  const { error, stdout, stderr, status } = spawnSync('./process-local.r', [], { input: dataParsedBuffer });
  if (error) {
    console.error(`exec error: ${error}`);
    return;
  }
  console.error(`[${id}] ${stderr}`);
  const result = stdout.toString('utf8').replace('[1] ', '').replace(/\"/g, '');
  console.debug(`[${id}] result: ${result}`);
  return result;
};

const updateMeasurement = async ({ measurement, processingResult }) => {
  const response = await api.patch(`/${measurement.id}`, {
    apikey,
    measurement: {
      processed: 1,
      c19_probability: processingResult,
    }
  })
};

const startSingleRecord = async () => {
  let page = 1;
  const measurement = await readMeasurements({ page });
  console.debug('Download done');
  const processingResult = processMeasurement(measurement);
  await updateMeasurement({ measurement, processingResult });
};

const startMultipleRecords = async () => {
  let page = 1;
  while (page) {
    const startTime = new Date();
    console.debug('Started page=', page);
    const responseResult = await readMeasurements({ page });
    const timeElapsed = ((new Date()) - startTime)/1000;
    console.debug('Download done. Time elapsed=', timeElapsed, ' seconds');
    const { data, meta } = responseResult;
    // console.log('data=', JSON.stringify(data,null,4));
    console.log('meta=', JSON.stringify(meta,null,4));
    page = meta.next_page;
    for (const measurement of data) {
      const processingResult = processMeasurement(measurement);
      await updateMeasurement({ measurement, processingResult });
    }
  }
  return true;
};

const start = async () => {
  console.debug('Start');
  if (singleMeasurementId) {
    await startSingleRecord();
  } else {
    await startMultipleRecords();
  }
};

start();
