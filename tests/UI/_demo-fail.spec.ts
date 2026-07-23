import { test, expect } from '@playwright/test';
import { captureBsSession } from '../../utils/browserstack';

// Link BrowserStack failures to their session in the ticket (no-op locally).
captureBsSession(test);

/**
 * DEMO: a test that FAILS on purpose, to try the Bug Report reporter.
 * Delete this file after you've seen bug-report/ and bug-image/.
 */
test.describe('Demo bug report', () => {
  test('intentionally fails to demo the bug report', async ({ page }) => {
    await page.setContent(
      '<main><h1>HUB24 Automation</h1><button>Continue</button></main>'
    );
    // This step passes:
    await expect(page.getByRole('heading', { name: 'HUB24 Automation' })).toBeVisible();
    // Now PASSES: the "Continue" button exists in the content above.
    await expect(
      page.getByRole('button', { name: 'Continue' })
    ).toBeVisible({ timeout: 3000 });
  });
});
