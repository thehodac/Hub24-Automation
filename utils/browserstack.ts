/**
 * BrowserStack helper: capture session details (dashboard URL + real OS, device,
 * browser) so the bug reporter can link the ticket to the exact session AND show
 * which device/OS/browser it ran on.
 *
 * BrowserStack exposes this through its "executor" — a no-op page.evaluate whose
 * argument is a special JSON command. On a normal (non-BrowserStack) browser this
 * returns nothing, so the hook is a safe no-op when running locally.
 */
import type { Page } from '@playwright/test';

export interface BsSession {
  url?: string;
  os?: string;
  device?: string;
  browser?: string;
}

/** BrowserStack session details for the current run, or null if not on BrowserStack. */
export async function bsSession(page: Page): Promise<BsSession | null> {
  try {
    const raw: unknown = await page.evaluate(
      (_cmd: string) => {},
      'browserstack_executor: {"action": "getSessionDetails"}',
    );
    if (typeof raw !== 'string') return null;
    const d = JSON.parse(raw) as {
      browser_url?: string; public_url?: string;
      os?: string; os_version?: string;
      device?: string;
      browser?: string; browser_version?: string;
    };
    const join = (a?: string, b?: string) => [a, b].filter(Boolean).join(' ') || undefined;
    return {
      url: d.browser_url || d.public_url,
      os: join(d.os, d.os_version),
      device: d.device || undefined,
      browser: join(d.browser, d.browser_version),
    };
  } catch {
    return null;
  }
}

/**
 * Register an afterEach that attaches the BrowserStack session URL + OS/device/
 * browser to the test (annotations), which the bug reporter puts into the ticket.
 * No-op when not running on BrowserStack.
 *
 * Call once at the top of each spec that runs on BrowserStack:
 *   captureBsSession(test);
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function captureBsSession(test: any): void {
  test.afterEach(
    async (
      { page }: { page: Page },
      testInfo: { annotations: { type: string; description?: string }[] },
    ): Promise<void> => {
      if (!process.env.BROWSERSTACK_USERNAME && !process.env.BROWSERSTACK) return;
      const s = await bsSession(page);
      if (!s) return;
      const push = (type: string, description?: string) => {
        if (description) testInfo.annotations.push({ type, description });
      };
      push('browserstack-url', s.url);
      push('bs-os', s.os);
      push('bs-device', s.device);
      push('bs-browser', s.browser);
    },
  );
}
