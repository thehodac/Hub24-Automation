import { defineConfig, devices } from '@playwright/test';
import { createRequire } from 'node:module';
// Load variables from a local .env file if `dotenv` is installed (optional).
// If dotenv isn't installed, env vars simply come from the shell instead.
try { createRequire(import.meta.url)('dotenv').config(); } catch { /* dotenv optional */ }

// BrowserStack runs (this config) save their report to a dedicated folder.
process.env.TEST_REPORT_DIR = process.env.TEST_REPORT_DIR || 'test-report-cloudbees-browserstack';

/**
 * Minimal Playwright config used ONLY for BrowserStack runs
 * (npm run test:browserstack).
 *
 * The real browsers / OS come from browserstack.yml (its `platforms` list).
 * Here we only pick WHICH specs to run — the UI smoke + accessibility specs —
 * on a single project, so the BrowserStack SDK maps that one project across
 * each platform instead of multiplying the 8 projects in playwright.config.ts.
 */
export default defineConfig({
  testDir: './tests',
  testMatch: ['**/UI/**/*.spec.ts', '**/accessibility/**/*.spec.ts'],
  // bug-report reporter -> auto-create Jira/Asana tickets on BrowserStack failures.
  reporter: [['list'], ['./reporters/bug-report.ts']],
  use: {
    baseURL: process.env.BASE_URL || 'https://playwright.dev',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
