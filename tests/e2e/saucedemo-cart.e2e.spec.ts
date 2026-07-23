import { test, expect, loginAsStandardUser } from '../../pages/saucedemo/fixtures';

test.use({ baseURL: 'https://www.saucedemo.com', storageState: { cookies: [], origins: [] } });

/** Module 3: Cart — TC_CART_001–006. */
test.describe('SauceDemo — Cart', () => {
  test.beforeEach(async ({ loginPage, inventoryPage }) => {
    await loginAsStandardUser(loginPage, inventoryPage);
  });

  test('TC_CART_001 cart page displays added items correctly', async ({ inventoryPage, cartPage }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.openCart();
    await cartPage.expectLoaded();
    await cartPage.expectItem('Sauce Labs Backpack');
    await expect(cartPage.itemDescriptions.first()).not.toBeEmpty();
    await expect(cartPage.itemPrices.first()).toContainText('$');
  });

  test('TC_CART_002 remove item from cart page', async ({ inventoryPage, cartPage }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.openCart();
    await cartPage.remove('Sauce Labs Backpack');
    await cartPage.expectEmpty();
    await cartPage.expectNoBadge();
  });

  test('TC_CART_003 continue shopping button returns to inventory', async ({ inventoryPage, cartPage, page }) => {
    await inventoryPage.openCart();
    await cartPage.continueShopping();
    await expect(page).toHaveURL(/inventory\.html/);
  });

  test('TC_CART_004 checkout button navigates to checkout step 1', async ({ inventoryPage, cartPage, page }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.openCart();
    await cartPage.checkout();
    await expect(page).toHaveURL(/checkout-step-one\.html/);
  });

  test('TC_CART_005 empty cart shows no items', async ({ inventoryPage, cartPage }) => {
    await inventoryPage.openCart();
    await cartPage.expectEmpty();
  });

  test('TC_CART_006 cart persists after page reload', async ({ inventoryPage, cartPage, page }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.openCart();
    await page.reload();
    await cartPage.expectBadgeCount('1');
    await cartPage.expectItem('Sauce Labs Backpack');
  });
});
