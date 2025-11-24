const express = require('express');
const { Camoufox } = require('camoufox');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

let browserPromise;

async function getBrowser() {
  if (!browserPromise) {
    const camoufox = new Camoufox({
      fingerprint: { mode: 'auto' },
      stealth: true,
      captcha: { mode: 'auto' },
    });

    browserPromise = camoufox.launch({
      headless: true,
      // Camoufox manages the browser binary and wraps Playwright with stealth defaults.
      // Additional options can be placed here when needed.
    });
  }

  return browserPromise;
}

async function visitUrl(url) {
  const browser = await getBrowser();
  // Each request gets its own isolated context so Camoufox can rotate fingerprints automatically.
  const context = await browser.newContext();
  const page = await context.newPage();

  const navigationTrail = [];
  page.on('framenavigated', (frame) => {
    if (frame === page.mainFrame()) {
      const currentUrl = frame.url();
      if (currentUrl && currentUrl !== 'about:blank') {
        navigationTrail.push(currentUrl);
      }
    }
  });

  let response;
  try {
    response = await page.goto(url, { waitUntil: 'networkidle' });
    // Let Cloudflare or other interstitials settle if the stealth layer triggers a challenge.
    await page.waitForTimeout(2000);
  } catch (error) {
    await context.close();
    throw error;
  }

  const redirectChain = [];
  try {
    const chain = response?.request?.().redirectChain?.();
    if (Array.isArray(chain)) {
      chain.forEach((request) => {
        if (request.url()) {
          redirectChain.push(request.url());
        }
      });
    }
  } catch (error) {
    // Some wrappers might not expose redirectChain; fall back to the navigation trail instead.
  }

  const redirects = redirectChain.length > 0 ? redirectChain : navigationTrail.slice(0, -1);
  const finalUrl = page.url();
  const html = await page.content();

  await context.close();

  return { html, finalUrl, redirects };
}

app.post('/visit', async (req, res) => {
  const { url } = req.body || {};
  if (!url || typeof url !== 'string') {
    return res.status(400).json({ error: 'A URL string is required.' });
  }

  try {
    const result = await visitUrl(url);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Failed to visit URL', details: error.message });
  }
});

app.get('/', (_req, res) => {
  res.json({ status: 'ok', message: 'Camoufox scraper server is running.' });
});

app.listen(port, () => {
  console.log(`Camoufox service listening on port ${port}`);
});
