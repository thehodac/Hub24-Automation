import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';
import { STORAGE_STATE } from './paths';
import { createRequire } from 'node:module';
// Load variables from a local .env file if `dotenv` is installed (optional).
// If dotenv isn't installed, env vars simply come from the shell instead.
try { createRequire(import.meta.url)('dotenv').config(); } catch { /* dotenv optional */ }

/**
 * Playwright configuration for HUB24 automation.
 * Set BASE_URL to the HUB24 environment, e.g.:
 *   BASE_URL=https://uat.hub24.example npm run test:e2e
 * Docs: https://playwright.dev/docs/test-configuration
 */

// Generate Playwright specs from .feature files + step definitions.
const bddDir = defineBddConfig({
  features: 'features/**/*.feature',
  steps: 'steps/**/*.ts',
});

// The default cross-browser projects only run UI + accessibility specs.
// e2e, auth, visual (Chromatic) and bdd each have their own project below.
const NON_DEFAULT = [/e2e/, /auth\.setup/, /chromatic/, /\/api\//];

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  // On CI, also emit JUnit XML so Cloudbees can show test results/trends.
  reporter: process.env.CI
    ? [['list'], ['junit', { outputFile: 'results/junit.xml' }], ['json', { outputFile: 'results/results.json' }], ['html', { open: 'never' }], ['./reporters/bug-report.ts']]
    : [['html', { open: 'never' }], ['list'], ['json', { outputFile: 'results/results.json' }], ['./reporters/bug-report.ts']],

  use: {
    baseURL: process.env.BASE_URL || 'https://playwright.dev',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    // Default cross-browser projects (UI + accessibility specs).
    { name: 'chromium', use: { ...devices['Desktop Chrome'] }, testIgnore: NON_DEFAULT },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] }, testIgnore: NON_DEFAULT },
    { name: 'webkit', use: { ...devices['Desktop Safari'] }, testIgnore: NON_DEFAULT },

    // Auth: logs in once, saves storageState for the e2e project.
    { name: 'setup', testMatch: /auth\.setup/ },

    // Regression / E2E suite — authenticated via storageState.
    //   npm run test:e2e
    {
      name: 'e2e',
      testDir: './tests/e2e',
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], storageState: STORAGE_STATE },
    },

    // Visual regression (Chromatic).  npm run test:visual
    {
      name: 'visual',
      testDir: './tests/chromatic',
      use: { ...devices['Desktop Chrome'] },
    },

    // API tests (Playwright request, no browser).  npm run test:api
    {
      name: 'api',
      testDir: './tests/api',
      use: { baseURL: process.env.API_URL || process.env.BASE_URL },
    },

    // BDD / Cucumber specs generated from features/ + steps/.  npm run bdd
    {
      name: 'bdd',
      testDir: bddDir,
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
