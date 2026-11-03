# Docs

This website is built using [Docusaurus 2](https://v2.docusaurus.io/), a modern
static website generator.

## Installation

```console
npm install
```

## Local Development

```console
npm start
```

This command starts a local development server and open up a browser window.
Most changes are reflected live without having to restart the server.

## Server directory checks

Run the server-detail regression tests with Node.js 18 or newer:

```console
node --test tests/server.test.mjs
```

The directory uses `https://api.open.mp/servers` for discovery and
`https://api.open.mp/servers/{host}:{port}` for metadata and server rules.
Details reflect open.mp's latest snapshot rather than a direct browser UDP query.
A failed detail lookup displays an unknown status and a links-unavailable message,
while retaining manually supplied links.
