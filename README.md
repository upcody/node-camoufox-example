# Camoufox Express Example

This project exposes a minimal Express server that controls a Camoufox browser session. It accepts a URL via REST API, drives the browser with stealth-friendly defaults, and returns the final HTML plus the redirect chain taken to reach it.

## Prerequisites

- Node.js 18+ with [Corepack](https://nodejs.org/api/corepack.html) enabled for `pnpm`
- Python 3.8+ with `pip`
- Access to the [camoufox-js](https://www.npmjs.com/package/camoufox-js) package (declared in `package.json`)

## Getting started

```bash
corepack enable pnpm
pnpm install
pip install -U "camoufox[geoip]"
camoufox fetch
pnpm start
```

The Python commands preload the Camoufox browser bundle (including GeoIP data) that the Node bindings expect. The server listens on port `3000` by default; set `PORT` to override.

## API

**POST `/visit`**

Request body:

```json
{ "url": "https://example.com" }
```

Response body:

```json
{
  "html": "<html>...</html>",
  "finalUrl": "https://example.com/landing",
  "redirects": ["https://example.com", "https://www.example.com"]
}
```

On success the response contains the final page HTML, the last resolved URL, and the redirects encountered. Each call runs inside a fresh Camoufox context to keep fingerprints isolated. Cloudflare or other bot checks are handled automatically by Camoufox's stealth layer.

`visit.http` contains a ready-to-send example request if you use VS Code’s REST Client or a similar tool.

## Docker

Build a slim container image with Camoufox (GeoIP-enabled) and its browser already installed:

```bash
docker build -t camoufox-server .
```

Run the server (exposes port 3000 by default):

```bash
docker run --rm -p 3000:3000 camoufox-server
```

Set `PORT` in `docker run` (for example `-e PORT=8080`) if you need a different port inside the container.

## Docker Compose

For local smoke tests you can use the included `docker-compose.yml`:

```bash
docker compose up --build
```

The compose file publishes port `3000` by default (or the value of `PORT` in your environment). When the container is running, exercise the API using `visit.http` or your preferred HTTP client.

## Example request

```http
POST /visit
Host: localhost:3000
Content-Type: application/json

{
  "url": "https://www.wsj.com/economy/trade/ceo-tariffs-earnings-calls-optimism-6e7aa423"
}
```
