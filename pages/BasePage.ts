import { Page } from '@playwright/test';

/**
 * BasePage holds behaviour shared by every page object.
 * Extend it for each concrete page.
 */
export abstract class BasePage {
  constructor(protected readonly page: Page) {}

  /** Navigate to a path relative to baseURL. */
  async goto(path = '/'): Promise<void> {
    await this.page.goto(path);
  }

  /** Current page title. */
  async title(): Promise<string> {
    return this.page.title();
  }
}
