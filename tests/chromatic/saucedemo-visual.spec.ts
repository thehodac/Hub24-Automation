import { test, expect } from '@chromatic-com/playwright';

// SauceDemo visual regression. Runs under the `visual` project. First run
// creates the baseline snapshots; later runs compare (before / after / diff).
test.use({ baseURL: 'https://www.saucedemo.com' });

/** Log in as standard_user and land on the inventory page (raw, no fixtures). */
async function login(page: import('@playwright/test').Page) {
  await page.goto('/');
  await page.fill('[data-test="username"]', 'standard_user');
  await page.fill('[data-test="password"]', 'secret_sauce');
  await page.click('[data-test="login-button"]');
  await expect(page.locator('[data-test="title"]')).toHaveText('Products');
}

/** Visual regression — TC_VIS_001–003. */
test.describe('SauceDemo — Visual regression (Chromatic)', () => {
  test('TC_VIS_001 login page matches baseline', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('[data-test="login-button"]')).toBeVisible();
    await expect(page).toHaveScreenshot('saucedemo-login.png', { fullPage: true });
  });

  test('TC_VIS_002 inventory page matches baseline', async ({ page }) => {
    await login(page);
    await expect(page).toHaveScreenshot('saucedemo-inventory.png', { fullPage: true });
  });

  test('TC_VIS_003 cart page matches baseline', async ({ page }) => {
    await login(page);
    await page.click('[data-test="add-to-cart-sauce-labs-backpack"]');
    await page.click('[data-test="shopping-cart-link"]');
    await expect(page).toHaveURL(/cart\.html/);
    // Small UI change (demo): recolour the Checkout button -> a visual regression
    // so this test differs from the clean baseline and creates a ticket.
    await page.addStyleTag({ content: '[data-test="checkout"] { background: #e91e63 !important; color: #fff !important; }' });
    await expect(page).toHaveScreenshot('saucedemo-cart.png', { fullPage: true });
  });
});
