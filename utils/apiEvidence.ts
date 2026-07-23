import type { TestInfo } from '@playwright/test';

/**
 * Evidence for an API call, attached to a test so the Bug Report reporter can
 * put it in the .docx AND render it into a .png (api tests have no browser, so
 * there is no real screenshot/video — this is the standard evidence instead).
 *
 * Usage in an api test:
 *   import { attachApiEvidence } from '../../utils/apiEvidence';
 *   test('...', async ({ request }, testInfo) => {
 *     const res = await request.get('/accounts/123');
 *     await attachApiEvidence(testInfo, {
 *       method: 'GET', url: '/accounts/123',
 *       status: res.status(), responseBody: await res.text(),
 *     });
 *     expect(res.status()).toBe(200);
 *   });
 */
export interface ApiEvidence {
  method: string;
  url: string;
  status?: number;
  requestHeaders?: Record<string, string>;
  requestBody?: unknown;
  responseHeaders?: Record<string, string>;
  responseBody?: unknown;
}

function fmt(v: unknown): string {
  if (v === undefined || v === null) return '';
  if (typeof v === 'string') return v;
  try { return JSON.stringify(v, null, 2); } catch { return String(v); }
}

export function formatApiEvidence(e: ApiEvidence): string {
  const lines: string[] = [];
  lines.push(`${e.method.toUpperCase()} ${e.url}`);
  if (e.status !== undefined) lines.push(`Status: ${e.status}`);
  if (e.requestHeaders && Object.keys(e.requestHeaders).length)
    lines.push('', 'Request headers:', fmt(e.requestHeaders));
  if (e.requestBody !== undefined && e.requestBody !== '')
    lines.push('', 'Request body:', fmt(e.requestBody));
  if (e.responseHeaders && Object.keys(e.responseHeaders).length)
    lines.push('', 'Response headers:', fmt(e.responseHeaders));
  if (e.responseBody !== undefined && e.responseBody !== '')
    lines.push('', 'Response body:', fmt(e.responseBody));
  return lines.join('\n');
}

export async function attachApiEvidence(testInfo: TestInfo, e: ApiEvidence): Promise<void> {
  await testInfo.attach('api-evidence', {
    body: formatApiEvidence(e),
    contentType: 'text/plain',
  });
}
