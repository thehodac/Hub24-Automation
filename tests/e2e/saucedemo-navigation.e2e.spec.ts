import { test, expect, loginAsStandardUser } from '../../pages/saucedemo/fixtures';

test.use({ baseURL: 'https://www.saucedemo.com', storageState: { cookies: [], origins: [] } });

/** Module 5: Navigation — TC_NAV_001–003. */
test.describe('SauceDemo — Navigation', () => {
  test.beforeEach(async ({ loginPage, inventoryPage }) => {
    await loginAsStandardUser(loginPage, inventoryPage);
  });

  test('TC_NAV_001 burger menu opens and closes', async ({ menuPage }) => {
    await menuPage.open();
    await menuPage.expectMenuOptions();
    await menuPage.close();
    await expect(menuPage.logoutLink).toBeHidden();
  });

  test('TC_NAV_002 reset app state clears cart', async ({ inventoryPage, menuPage }) => {
    await inventoryPage.addToCart('Sauce Labs Backpack');
    await inventoryPage.expectBadgeCount('1');
    await menuPage.resetAppState();
    await menuPage.close();
    await inventoryPage.expectNoBadge();
    await expect(inventoryPage.addToCartButton('Sauce Labs Backpack')).toBeVisible();
  });

  test('TC_NAV_003 all items menu link returns to inventory', async ({ inventoryPage, menuPage, page }) => {
    await inventoryPage.openProduct('Sauce Labs Backpack');
    await expect(page).toHaveURL(/inventory-item\.html/);
    await menuPage.goToAllItems();
    await expect(page).toHaveURL(/inventory\.html/);
  });
});
