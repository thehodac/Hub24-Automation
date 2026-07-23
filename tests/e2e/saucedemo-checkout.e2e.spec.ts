import { test, expect, loginAsStandardUser } from '../../pages/saucedemo/fixtures';
import type { InventoryPage } from '../../pages/saucedemo/InventoryPage';
import type { CartPage } from '../../pages/saucedemo/CartPage';

test.use({ baseURL: 'https://www.saucedemo.com', storageState: { cookies: [], origins: [] } });

/** Module 4: Checkout — TC_CHK_001–011. */
test.describe('SauceDemo — Checkout', () => {
  test.beforeEach(async ({ loginPage, inventoryPage }) => {
    await loginAsStandardUser(loginPage, inventoryPage);
  });

  /** Add one item and land on checkout step 1. */
  async function toStepOne(inventoryPage: InventoryPage, cartPage: CartPage) {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.openCart();
    await cartPage.checkout();
  }

  test('TC_CHK_001 proceed to step 2 with valid info', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.expectStepOne();
    await checkoutPage.fillInformation('John', 'Doe', '10001');
    await checkoutPage.continue();
    await checkoutPage.expectStepTwo();
  });

  test('TC_CHK_002 checkout fails with empty first name', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('', 'Doe', '10001');
    await checkoutPage.continue();
    await checkoutPage.expectError('First Name is required');
  });

  test('TC_CHK_003 checkout fails with empty last name', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', '', '10001');
    await checkoutPage.continue();
    await checkoutPage.expectError('Last Name is required');
  });

  test('TC_CHK_004 checkout fails with empty zip code', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', 'Doe', '');
    await checkoutPage.continue();
    await checkoutPage.expectError('Postal Code is required');
  });

  test('TC_CHK_005 cancel on step 1 returns to cart', async ({ inventoryPage, cartPage, checkoutPage, page }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.cancel();
    await expect(page).toHaveURL(/cart\.html/);
  });

  test('TC_CHK_006 cancel on step 2 returns to inventory', async ({ inventoryPage, cartPage, checkoutPage, page }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', 'Doe', '10001');
    await checkoutPage.continue();
    await checkoutPage.expectStepTwo();
    await checkoutPage.cancel();
    await expect(page).toHaveURL(/inventory\.html/);
  });

  test('TC_CHK_007 order total is correctly calculated on step 2', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', 'Doe', '10001');
    await checkoutPage.continue();
    const subtotal = await checkoutPage.subtotal();
    const tax = await checkoutPage.tax();
    const total = await checkoutPage.total();
    expect(subtotal).toBeGreaterThan(0);
    expect(total).toBeCloseTo(subtotal + tax, 2);
  });

  test('TC_CHK_008 back home button on confirmation returns to inventory', async ({ inventoryPage, cartPage, checkoutPage, page }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', 'Doe', '10001');
    await checkoutPage.continue();
    await checkoutPage.finish();
    await checkoutPage.expectConfirmation();
    await checkoutPage.backHome();
    await expect(page).toHaveURL(/inventory\.html/);
    await expect(inventoryPage.cartBadge).toBeHidden();
  });

  test('TC_CHK_009 order summary shows all price components on step 2', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', 'Doe', '10001');
    await checkoutPage.continue();
    await checkoutPage.expectSummaryVisible();
  });

  test('TC_CHK_010 complete full checkout flow — finish button', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', 'Doe', '10001');
    await checkoutPage.continue();
    await checkoutPage.finish();
    await checkoutPage.expectConfirmation();
  });

  test('TC_CHK_011 order confirmation shows success message', async ({ inventoryPage, cartPage, checkoutPage }) => {
    await toStepOne(inventoryPage, cartPage);
    await checkoutPage.fillInformation('John', 'Doe', '10001');
    await checkoutPage.continue();
    await checkoutPage.finish();
    await expect(checkoutPage.completeHeader).toBeVisible();
    await expect(checkoutPage.completeHeader).toContainText('Thank you for your order');
  });
});
