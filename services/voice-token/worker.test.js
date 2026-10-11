import test from 'node:test';
import assert from 'node:assert/strict';
import {createWorker} from './worker.js';
const env = () => ({GEMINI_API_KEY: 'server-secret', REQUEST_LIMIT: {limit: async () => ({success: true})}, TOKEN_LIMIT: {limit: async () => ({success: true})}});
const request = () => new Request('https://example.test/token', {method: 'POST'});
test('no tester credential is required', async () => {
  const response = await createWorker(async () => ({name: 'temporary'})).fetch(request(), env());
  assert.equal(response.status, 200);
});
test('token is one-use, short-lived, locked to transcription', async () => {
  let config;
  const worker = createWorker(async (_, value) => {config = value; return {name: 'temporary'};});
  const response = await worker.fetch(request(), env());
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.equal(config.uses, 1);
  assert.equal(config.liveConnectConstraints.model, 'gemini-3.5-transcribe-live');
  assert.deepEqual(config.liveConnectConstraints.config.responseModalities, ['TEXT']);
  assert.ok(Date.parse(config.expireTime) - Date.now() <= 360000);
  assert.equal((await response.json()).token, 'temporary');
});
test('rate limited and unconfigured requests fail closed', async () => {
  const worker = createWorker(() => {throw Error('must not mint');});
  assert.equal((await worker.fetch(request(), {})).status, 503);
  const limited = env(); limited.TOKEN_LIMIT.limit = async () => ({success: false});
  assert.equal((await worker.fetch(request(), limited)).status, 429);
});
test('provider errors never expose secrets', async () => {
  const response = await createWorker(() => {throw Error('server-secret');}).fetch(request(), env());
  assert.equal(response.status, 502);
  assert.ok(!(await response.text()).includes('server-secret'));
});
