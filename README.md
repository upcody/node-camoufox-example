# Camoufox Express Example

This project exposes a minimal Express server that controls a Camoufox browser session. It accepts a URL via REST API, drives the browser with stealth-friendly defaults, and returns the final HTML plus the redirect chain taken to reach it.

## Prerequisites

- Node.js 18+
- Access to the [Camoufox](https://www.npmjs.com/package/camoufox) package (the dependency is declared in `package.json`).

## Getting started

```bash
npm install
npx camoufox install --geoip
npm run start
```

The server listens on port `3000` by default. Set `PORT` to override.

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
