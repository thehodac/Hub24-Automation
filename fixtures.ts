/**
 * Shared Playwright test fixtures: inject page objects so specs (and
 * Claude Code-generated tests) stay clean — `async ({ examplePage })`
 * instead of `new ExamplePage(page)` in every test.
 *
 * Import `test` and `expect` from this file instead of '@playwright/test'.
 * Add one fixture per HUB24 page object as you build them.
 */
import { test as base } from '@playwright/test';
import { ExamplePage } from './pages/hub24/ExamplePage';

type Hub24Fixtures = {
  examplePage: ExamplePage;
};

export const test = base.extend<Hub24Fixtures>({
  examplePage: async ({ page }, use) => {
    await use(new ExamplePage(page));
  },
});

export { expect } from '@playwright/test';
