import { test, loginAsStandardUser } from '../../pages/saucedemo/fixtures';
import { checkA11y } from '../../utils/a11y';
import { captureBsSession } from '../../utils/browserstack';

// Link BrowserStack failures to their session in the ticket (no-op locally).
captureBsSession(test);

// SauceDemo accessibility checks (axe-core, WCAG 2.1 A/AA). Runs under the
// default chromium project. Override baseURL + skip the HUB24 storageState.
test.use({ baseURL: 'https://www.saucedemo.com', storageState: { cookies: [], origins: [] } });

/**
 * Accessibility — TC_A11Y_001–004.
 * Reuses the SauceDemo page objects to reach each page, then runs an axe-core
 * WCAG 2.1 A/AA scan via checkA11y (utils/a11y.ts). checkA11y asserts zero
 * violations, so a real a11y issue on SauceDemo will fail the test (by design —
 * it demonstrates the accessibility → bug flow).
 */
test.describe('SauceDemo — Accessibility (axe-core, WCAG 2.1 A/AA)', () => {
  test('TC_A11Y_001 login page has no WCAG A/AA violations', async ({ page, loginPage }, testInfo) => {
    await loginPage.open();
    await checkA11y(page, testInfo);
  });

  test('TC_A11Y_002 inventory page has no WCAG A/AA violations', async ({ page, loginPage, inventoryPage }, testInfo) => {
    await loginAsStandardUser(loginPage, inventoryPage);
    await checkA11y(page, testInfo);
  });

  test('TC_A11Y_003 cart page has no WCAG A/AA violations', async ({ page, loginPage, inventoryPage }, testInfo) => {
    await loginAsStandardUser(loginPage, inventoryPage);
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.openCart();
    await checkA11y(page, testInfo);
  });

  test('TC_A11Y_004 checkout info page has no WCAG A/AA violations', async ({ page, loginPage, inventoryPage, cartPage }, testInfo) => {
    await loginAsStandardUser(loginPage, inventoryPage);
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.openCart();
    await cartPage.checkout();
    await checkA11y(page, testInfo);
  });
});
