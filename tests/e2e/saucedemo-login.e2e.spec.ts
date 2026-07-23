import { test, expect } from '../../pages/saucedemo/fixtures';

// SauceDemo runs under the e2e project but against its own site, so override
// the HUB24 baseURL and skip the HUB24 storageState for these specs.
test.use({ baseURL: 'https://www.saucedemo.com', storageState: { cookies: [], origins: [] } });

/**
 * Module 1: Login — TC_LOGIN_001–008.
 * Site: https://www.saucedemo.com
 */
test.describe('SauceDemo — Login', () => {
  test.beforeEach(async ({ loginPage }) => {
    await loginPage.open();
  });

  test('TC_LOGIN_001 login successfully with standard user', async ({ loginPage, inventoryPage }) => {
    await loginPage.login('standard_user', 'secret_sauce');
    await inventoryPage.expectLoaded();
    // Named assertion -> a clear failure message instead of a generic "element not found".
    await expect(inventoryPage.items.first(), 'First product should be visible on the inventory page').toBeVisible();
  });

  test('TC_LOGIN_002 login fails for locked out user', async ({ loginPage }) => {
    await loginPage.login('locked_out_user', 'secret_sauce');
    await loginPage.expectError('Sorry, this user has been locked out');
  });

  test('TC_LOGIN_003 login with empty username shows error', async ({ loginPage }) => {
    await loginPage.login('', 'secret_sauce');
    await loginPage.expectError('Username is required');
  });

  test('TC_LOGIN_004 login with empty password shows error', async ({ loginPage }) => {
    await loginPage.login('standard_user', '');
    await loginPage.expectError('Password is required');
  });

  test('TC_LOGIN_005 login with invalid credentials shows error', async ({ loginPage }) => {
    await loginPage.login('invalid_user', 'wrong_pass');
    await loginPage.expectError('Username and password do not match');
  });

  test('TC_LOGIN_006 error message clears when X button is clicked', async ({ loginPage }) => {
    await loginPage.login('', '');
    await loginPage.expectError('Username is required');
    await loginPage.clearError();
    await expect(loginPage.error).toBeHidden();
  });

  test('TC_LOGIN_007 login with performance glitch user succeeds (slow)', async ({ loginPage, inventoryPage }) => {
    test.setTimeout(30_000);
    await loginPage.login('performance_glitch_user', 'secret_sauce');
    await expect(inventoryPage.pageTitle).toHaveText('Products', { timeout: 15_000 });
  });

  test('TC_LOGIN_008 logout successfully returns to login page', async ({ loginPage, inventoryPage, menuPage }) => {
    await loginPage.login('standard_user', 'secret_sauce');
    await inventoryPage.expectLoaded();
    await menuPage.logout();
    await loginPage.expectOnLoginPage();
  });
});
