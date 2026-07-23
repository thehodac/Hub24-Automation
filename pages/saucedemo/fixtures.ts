/**
 * SauceDemo test fixtures — inject page objects so demo specs stay clean
 * (`async ({ loginPage }) => { ... }` instead of `new LoginPage(page)`).
 *
 * Import `test` and `expect` from this file in tests/saucedemo/*.spec.ts.
 * This suite is independent of HUB24 (own baseURL, no storageState/auth).
 */
import { test as base } from '@playwright/test';
import { attachTestParams } from '../../utils/testMeta';
import { LoginPage } from './LoginPage';
import { InventoryPage } from './InventoryPage';
import { CartPage } from './CartPage';
import { CheckoutPage } from './CheckoutPage';
import { MenuPage } from './MenuPage';

type SauceFixtures = {
  loginPage: LoginPage;
  inventoryPage: InventoryPage;
  cartPage: CartPage;
  checkoutPage: CheckoutPage;
  menuPage: MenuPage;
};

export const test = base.extend<SauceFixtures & { autoTestParams: void }>({
  loginPage: async ({ page }, use) => { await use(new LoginPage(page)); },
  inventoryPage: async ({ page }, use) => { await use(new InventoryPage(page)); },
  cartPage: async ({ page }, use) => { await use(new CartPage(page)); },
  checkoutPage: async ({ page }, use) => { await use(new CheckoutPage(page)); },
  menuPage: async ({ page }, use) => { await use(new MenuPage(page)); },
  // Auto fixture: attach test parameters (user inputs) to EVERY spec that uses
  // this `test`, so every auto-created ticket shows a "Test parameters" section.
  autoTestParams: [
    async ({}, use, testInfo) => {
      const moduleName = (testInfo.file.split(/[\\/]/).pop() || '')
        .replace(/\.(e2e\.)?spec\.ts$/, '')
        .replace(/^saucedemo-/, '');
      attachTestParams(testInfo, { user: 'standard_user', module: moduleName });
      await use();
    },
    { auto: true },
  ],
});

/** Log in as standard_user and land on the inventory page. */
export async function loginAsStandardUser(loginPage: LoginPage, inventoryPage: InventoryPage): Promise<void> {
  await loginPage.open();
  await loginPage.login('standard_user', 'secret_sauce');
  await inventoryPage.expectLoaded();
}

export { expect } from '@playwright/test';
