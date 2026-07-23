import { test, expect, loginAsStandardUser } from '../../pages/saucedemo/fixtures';

test.use({ baseURL: 'https://www.saucedemo.com', storageState: { cookies: [], origins: [] } });

/** Module 2: Inventory / Product list — TC_INV_001–010. */
test.describe('SauceDemo — Inventory', () => {
  test.beforeEach(async ({ loginPage, inventoryPage }) => {
    await loginAsStandardUser(loginPage, inventoryPage);
  });

  test('TC_INV_001 inventory page displays 6 products', async ({ inventoryPage }) => {
    await inventoryPage.expectProductCount(6);
  });

  test('TC_INV_002 sort products A to Z', async ({ inventoryPage }) => {
    await inventoryPage.sortBy('az');
    const names = await inventoryPage.productNames();
    expect(names).toEqual([...names].sort((a, b) => a.localeCompare(b)));
  });

  test('TC_INV_003 sort products Z to A', async ({ inventoryPage }) => {
    await inventoryPage.sortBy('za');
    const names = await inventoryPage.productNames();
    expect(names).toEqual([...names].sort((a, b) => b.localeCompare(a)));
  });

  test('TC_INV_004 sort products by price low to high', async ({ inventoryPage }) => {
    await inventoryPage.sortBy('lohi');
    const prices = await inventoryPage.productPrices();
    expect(prices).toEqual([...prices].sort((a, b) => a - b));
  });

  test('TC_INV_005 sort products by price high to low', async ({ inventoryPage }) => {
    await inventoryPage.sortBy('hilo');
    const prices = await inventoryPage.productPrices();
    expect(prices).toEqual([...prices].sort((a, b) => b - a));
  });

  test('TC_INV_006 add item to cart shows badge count', async ({ inventoryPage }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.expectBadgeCount('1');
  });

  test('TC_INV_007 add multiple items to cart updates badge', async ({ inventoryPage }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.addToCart('Sauce Labs Bike Light');
    await inventoryPage.expectBadgeCount('2');
  });

  test('TC_INV_008 remove item from inventory page hides badge', async ({ inventoryPage }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.expectBadgeCount('1');
    await inventoryPage.removeFromInventory('Sauce Labs Backpack');
    await inventoryPage.expectNoBadge();
  });

  test('TC_INV_009 click product name navigates to detail page', async ({ inventoryPage, page }) => {
    await inventoryPage.openProduct('Sauce Labs Backpack');
    await expect(page).toHaveURL(/inventory-item\.html/);
    await expect(page.locator('[data-test="inventory-item-name"]')).toContainText('Sauce Labs Backpack');
  });

  test('TC_INV_010 click cart icon navigates to cart page', async ({ inventoryPage, page }) => {
    await inventoryPage.openCart();
    await expect(page).toHaveURL(/cart\.html/);
  });
});
