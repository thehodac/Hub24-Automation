import { defineConfig } from '@playwright/test';
import baseConfig from './playwright.config';

/**
 * Slow-motion DEMO config (for recording the SauceDemo run for Kat).
 * Same projects as playwright.config.ts, but Chromium runs headed and each
 * action is delayed by `slowMo` ms so every step is easy to follow on video.
 *
 * Run:  npm run test:saucedemo:demo
 * Tune speed:  set SLOWMO (ms), e.g. SLOWMO=2500 for even slower (default 1800).
 *
 * This file is only for the demo — safe to delete when clearing SauceDemo.
 */
export default defineConfig({
  ...baseConfig,
  workers: 1,           // one test at a time so the video is a single, linear flow
  fullyParallel: false, // don't run files in parallel — keep it strictly sequential
  use: {
    ...baseConfig.use,
    headless: false,
    actionTimeout: 15_000,
    launchOptions: { slowMo: Number(process.env.SLOWMO) || 1800 }, // ms delay between each action
  },
});
