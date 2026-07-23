/**
 * Attach the test parameters / user inputs used by a test, so the bug reporter
 * can show them in the ticket ("Test parameters (user inputs)"). Mask secrets
 * yourself before passing them (e.g. password: '***').
 *
 * Usage inside a test:
 *   test('login', async ({ page }, testInfo) => {
 *     attachTestParams(testInfo, { username: 'standard_user', password: '***' });
 *     ...
 *   });
 */
import type { TestInfo } from '@playwright/test';

export function attachTestParams(
  testInfo: TestInfo,
  params: Record<string, string | number | boolean>,
): void {
  const text = Object.entries(params)
    .map(([k, v]) => `${k}=${v}`)
    .join('; ');
  if (text) testInfo.annotations.push({ type: 'test-parameters', description: text });
}
