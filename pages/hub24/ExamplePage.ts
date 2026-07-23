import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from '../BasePage';

/**
 * TEMPLATE page object for HUB24.
 *
 * Copy this pattern for each real HUB24 page (one class per page). Put all
 * locators in the constructor and expose actions/assertions as methods so
 * specs never touch raw selectors.
 *
 * Replace the placeholder selectors below with real HUB24 elements
 * (prefer data-test attributes or getByRole over brittle CSS).
 */
export class ExamplePage extends BasePage {
  readonly heading: Locator;

  constructor(page: Page) {
    super(page);
    // TODO(HUB24): replace with a real, stable locator for this page.
    this.heading = page.getByRole('heading', { level: 1 });
  }

  /** Navigate to this page (path is relative to baseURL). */
  async open(path = '/'): Promise<void> {
    await this.goto(path);
  }

  /** Assert the page has loaded. */
  async expectLoaded(): Promise<void> {
    await expect(this.heading).toBeVisible();
  }
}
