/**
 * TEMPLATE auth setup for HUB24: log in once and persist the session to
 * storageState so the regression/E2E suite can reuse it (no per-test login).
 * Runs automatically as a dependency of the `e2e` project.
 *
 * Fill in the real HUB24 login steps below, then set TEST_USER / TEST_PASSWORD
 * (see .env.example) and BASE_URL.
 */
import { test as setup } from '@playwright/test';
import { STORAGE_STATE } from '../paths';

setup('authenticate', async ({ page }) => {
  // TODO(HUB24): implement the real login flow, e.g.:
  // await page.goto('/login');
  // await page.getByLabel('Username').fill(process.env.TEST_USER!);
  // await page.getByLabel('Password').fill(process.env.TEST_PASSWORD!);
  // await page.getByRole('button', { name: 'Sign in' }).click();
  // await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();

  await page.context().storageState({ path: STORAGE_STATE });
});
