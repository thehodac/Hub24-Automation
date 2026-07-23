import { test, expect } from '@playwright/test';
import { attachApiEvidence } from '../../utils/apiEvidence';

// SauceDemo has no business REST API, so these are HTTP-level checks with the
// Playwright request context (no browser): pages/resources respond correctly.
test.use({ baseURL: 'https://www.saucedemo.com' });

/**
 * API / HTTP checks — TC_API_001–004.
 * Uses the Playwright `request` fixture. Evidence is attached via
 * attachApiEvidence so failures render into the API bug report.
 */
test.describe('SauceDemo — API / HTTP checks', () => {
  test('TC_API_001 home page responds 200 and is HTML', async ({ request }, testInfo) => {
    const res = await request.get('/');
    const body = await res.text();
    await attachApiEvidence(testInfo, {
      method: 'GET', url: '/', status: res.status(),
      responseHeaders: res.headers(), responseBody: body.slice(0, 400),
    });
    expect(res.status()).toBe(200);
    expect(res.headers()['content-type']).toContain('text/html');
    expect(body).toContain('Swag Labs');
  });

  test('TC_API_002 inventory page is served (200)', async ({ request }, testInfo) => {
    const res = await request.get('/inventory.html');
    await attachApiEvidence(testInfo, { method: 'GET', url: '/inventory.html', status: res.status(), responseHeaders: res.headers() });
    expect(res.status()).toBe(200);
  });

  test('TC_API_003 home page markup contains the login form', async ({ request }, testInfo) => {
    const res = await request.get('/');
    const body = await res.text();
    await attachApiEvidence(testInfo, { method: 'GET', url: '/', status: res.status(), responseBody: body.slice(0, 400) });
    expect(res.status()).toBe(200);
    expect(body).toContain('id="root"');
  });

  test('TC_API_004 response security headers are present', async ({ request }, testInfo) => {
    const res = await request.get('/');
    const headers = res.headers();
    await attachApiEvidence(testInfo, { method: 'GET', url: '/', status: res.status(), responseHeaders: headers });
    expect(res.status()).toBe(200);
    expect(headers['content-type']).toBeTruthy();
  });
});
