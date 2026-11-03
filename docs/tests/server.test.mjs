import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';

// Load the browser ES module without changing the Docusaurus package module type.
const source = await readFile(new URL('../src/models/Server.js', import.meta.url), 'utf8');
const { default: Server } = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
const core = { hn: 'Scavenge and Survive Vanilla', la: 'PT/BR' };

function mockResponse(t, body, status = 200) {
  t.mock.method(globalThis, 'fetch', async () => new Response(JSON.stringify(body), { status }));
}

test('recovers the Discord invite from the open.mp detail response', async t => {
  mockResponse(t, { core, ru: { weburl: 'discord.gg/bThMb7vrXM', weather: '10' } });
  const server = new Server({ address: '172.96.140.62:10869' });
  await server.refresh();
  assert.equal(server.links.weburl, 'https://discord.gg/bThMb7vrXM');
  assert.equal(server.name, core.hn);
  assert.equal(server.language, 'PT/BR');
  assert.equal(server.online, true);
  assert.equal(server.linksUnavailable, false);
  assert.equal(globalThis.fetch.mock.calls.length, 1);
  assert.equal(globalThis.fetch.mock.calls[0].arguments[0], 'https://api.open.mp/servers/172.96.140.62:10869');
});

test('keeps curated links and accepts custom HTTP(S) rule links', async t => {
  mockResponse(t, { core, ru: { discord: 'https://discord.gg/example', forum: 'example.com/forum', weather: 10, weburl: 'javascript:alert(1)' } });
  const server = new Server({ address: 'example.com:7777', links: { website: 'https://example.org/' } });
  await server.refresh();
  assert.deepEqual(server.links, { website: 'https://example.org/', discord: 'https://discord.gg/example', forum: 'https://example.com/forum' });
});

test('failed lookups preserve curated links and report unknown status', async t => {
  mockResponse(t, {}, 404);
  t.mock.method(console, 'error', () => {});
  const server = new Server({ address: 'example.com:7777', online: true, links: { discord: 'https://discord.gg/example' } });
  await server.refresh();
  assert.equal(server.online, null);
  assert.equal(server.linksUnavailable, true);
  assert.equal(server.links.discord, 'https://discord.gg/example');
});

test('distinguishes missing rules from a successful lookup with no links', async t => {
  mockResponse(t, { core, ru: null });
  const server = new Server({ address: 'example.com:7777' });
  await server.refresh();
  assert.equal(server.online, true);
  assert.equal(server.linksUnavailable, true);
  globalThis.fetch.mock.mockImplementation(async () => new Response(JSON.stringify({ core, ru: {} })));
  await server.refresh();
  assert.equal(server.linksUnavailable, false);
  assert.deepEqual(server.links, {});
});

test('a stalled request is aborted and leaves the row usable', async t => {
  t.mock.method(console, 'error', () => {});
  t.mock.method(globalThis, 'setTimeout', callback => { queueMicrotask(callback); return 1; });
  t.mock.method(globalThis, 'clearTimeout', () => {});
  t.mock.method(globalThis, 'fetch', (_, { signal }) => new Promise((resolve, reject) => {
    signal.addEventListener('abort', () => reject(new Error('Aborted')), { once: true });
  }));
  const server = new Server({ address: 'example.com:7777' });
  await server.refresh();
  assert.equal(server.online, null);
  assert.equal(server.linksUnavailable, true);
});
