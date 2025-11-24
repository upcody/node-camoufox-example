import express from 'express';
import { launchOptions } from 'camoufox-js';
import { firefox } from 'playwright-core';

const browserPromise = firefox.launch({
    acceptDownloads: false,
    ...await launchOptions({
        geoip: true,
        headless: true,
        humanize: true,
    }),
});

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

async function visitUrl(url) {
  const browser = await browserPromise;

  // each request gets its own isolated context so Camoufox can rotate fingerprints automatically.
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    await page.goto(url, { waitUntil: 'load' });
    await page.waitForSelector('iframe[src*="captcha"]', { state: 'hidden' });
  } catch (error) {
    await context.close();
    throw error;
  }

  const result = {
      url:page.url(),
      html :await page.content(),
  }

  await context.close();
  return result;
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
