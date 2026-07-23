import { createBdd } from 'playwright-bdd';
import { ExamplePage } from '../pages/hub24/ExamplePage';

/**
 * TEMPLATE step definitions for HUB24. Each step calls a page object —
 * keep selectors out of step files.
 */
const { Given, Then } = createBdd();

Given('I open the HUB24 home page', async ({ page }) => {
  await new ExamplePage(page).open('/');
});

Then('I should see the page loaded', async ({ page }) => {
  await new ExamplePage(page).expectLoaded();
});
