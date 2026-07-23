import { test, expect } from '@playwright/test';
import { captureBsSession } from '../../utils/browserstack';

// Link BrowserStack failures to their session in the ticket (no-op locally).
captureBsSession(test);

/**
 * Offline smoke test — proves Playwright + the browsers are installed and
 * working, without needing any external website. Replace with real HUB24
 * UI specs once BASE_URL points at the HUB24 app.
 */
test.describe('Smoke', () => {
  test('the browser can render and query a page', async ({ page }) => {
    await page.setContent(
      '<main><h1>HUB24 Automation</h1><button>Continue</button></main>'
    );
    await expect(page.getByRole('heading', { name: 'HUB24 Automation' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Continue' })).toBeEnabled();
  });
});
