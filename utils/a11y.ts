import { Page, expect, TestInfo } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

const DEFAULT_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'];

interface ScanOptions {
  /** WCAG tags to run against. Defaults to WCAG 2.1 A & AA. */
  tags?: string[];
  /** CSS selectors to exclude from the scan (e.g. third-party widgets). */
  exclude?: string[];
}

/**
 * Run an axe-core accessibility scan on the current page, attach the full
 * results to the test report, and assert there are zero violations.
 */
export async function checkA11y(
  page: Page,
  testInfo: TestInfo,
  options: ScanOptions = {}
): Promise<void> {
  let builder = new AxeBuilder({ page }).withTags(options.tags ?? DEFAULT_TAGS);

  for (const selector of options.exclude ?? []) {
    builder = builder.exclude(selector);
  }

  const results = await builder.analyze();

  await testInfo.attach('axe-results.json', {
    body: JSON.stringify(results.violations, null, 2),
    contentType: 'application/json',
  });

  expect(
    results.violations,
    formatViolations(results.violations)
  ).toEqual([]);
}

function formatViolations(
  violations: Awaited<ReturnType<AxeBuilder['analyze']>>['violations']
): string {
  if (violations.length === 0) return 'No accessibility violations.';
  return violations
    .map(
      (v) =>
        `[${v.impact}] ${v.id}: ${v.help} (${v.nodes.length} node(s))\n  ${v.helpUrl}`
    )
    .join('\n');
}
