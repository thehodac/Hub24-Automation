/**
 * Bug Report reporter for HUB24 Playwright.
 *
 * One file per issue, grouped by test category. The category comes from the
 * test's folder under tests/ (e2e, api, accessibility, chromatic, UI, ...).
 * Files land in a "bug-<category>" sub-folder of each output folder:
 *   bug-report/bug-<cat>/[STATUS][ISSUE-NN] <describe> - <title>.docx
 *   bug-image/bug-<cat>/ ... .png
 *   bug-video/bug-<cat>/ ... .webm
 *
 * STATUS lives only in the FILENAME. On a re-run:
 *   - failing -> prefix [FAIL], refresh evidence
 *   - passing -> rename prefix [FAIL]->[PASS], KEEP all content
 * Every run appends a "Change history" line (status + Vietnam-time date) to the
 * .docx. History is remembered in bug-report/bug-<cat>/.history/<ISSUE-NN>.json
 * and is NOT added to the Jira ticket.
 *
 * Creates a Jira ticket per failure when JIRA_CREATE_TICKETS=true.
 * Requires: npm install docx --save-dev
 * API tests: attach evidence via utils/apiEvidence -> shown in docx + rendered to PNG.
 */
import type {
  Reporter,
  TestCase,
  TestResult,
  TestStep,
  FullResult,
} from '@playwright/test/reporter';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { createBugTickets, resolveFixedTicket, type JiraBug } from './jira';
import { createAsanaTasks, resolveFixedAsanaTask } from './asana';
import { createAzureWorkItems, resolveFixedAzureWorkItem } from './azuredevops';
import { createBasecampTodos, resolveFixedBasecampTodo } from './basecamp';

const ANSI = /\x1b\[[0-9;]*m/g;
const strip = (s = ''): string =>
  s
    .replace(ANSI, '')
    .split('')
    .filter((ch) => {
      const n = ch.charCodeAt(0);
      return n === 9 || n === 10 || n === 13 || n >= 32;
    })
    .join('')
    .trim();

interface FailedCase extends JiraBug {
  issueId: string;
  apiEvidence?: string;
  chromaticUrl?: string;
  visual?: { before?: string; after?: string; diff?: string };
}
interface HistoryEntry {
  status: 'FAIL' | 'PASS';
  date: string;
}
interface IssueRecord {
  issueId: string;
  caseName: string;
  details: FailedCase;
  history: HistoryEntry[];
}
interface Dirs {
  report: string;
  image: string;
  video: string;
  history: string;
}

const RE_ISSUE = /\[(FAIL|PASS)\]\[(ISSUE-\d+)\]/;

export default class BugReportReporter implements Reporter {
  private cases = new Map<string, { test: TestCase; result: TestResult }>();
  private readonly bugReportDir = path.resolve('bug-report');
  private readonly bugImageDir = path.resolve('bug-image');
  private readonly bugVideoDir = path.resolve('bug-video');

  onBegin(): void {
    for (const d of [this.bugReportDir, this.bugImageDir, this.bugVideoDir])
      fs.mkdirSync(d, { recursive: true });
  }

  onTestEnd(test: TestCase, result: TestResult): void {
    this.cases.set(test.id, { test, result });
  }

  async onEnd(_r: FullResult): Promise<void> {
    let total = 0;
    let passed = 0;
    let failed = 0;
    const failCases: { test: TestCase; result: TestResult }[] = [];
    const passCases: TestCase[] = [];
    const byCat = new Map<string, { total: number; passed: number; failed: number }>();

    for (const c of this.cases.values()) {
      total += 1;
      const cat = this.category(c.test);
      const tally = byCat.get(cat) ?? { total: 0, passed: 0, failed: 0 };
      tally.total += 1;
      if (c.result.status === 'passed') { passed += 1; passCases.push(c.test); tally.passed += 1; }
      else if (c.result.status === 'failed' || c.result.status === 'timedOut') {
        failed += 1; failCases.push(c); tally.failed += 1;
      }
      byCat.set(cat, tally);
    }

    const summary = `📊 Total: ${total} | Passed: ${passed} | Failed: ${failed}`;
    console.log(`\n${summary}\n`);

    let docx: typeof import('docx') | null = null;
    if (failCases.length > 0 || passCases.length > 0) {
      try { docx = await import('docx'); }
      catch { console.log('⚠️  docx not installed — run: npm install docx --save-dev'); }
    }

    const failures: FailedCase[] = [];
    const counters = new Map<string, number>();

    // --- failures ---
    for (const { test, result } of failCases) {
      const cat = this.category(test);
      const dirs = this.dirsFor(cat);
      this.ensureDirs(dirs);

      const fc = this.buildFailedCase(test, result);
      const caseName = this.sanitize(`${fc.funcSpec} - ${fc.title}`);
      const existing = this.findExistingIssue(dirs, caseName);

      if (!counters.has(cat)) counters.set(cat, this.currentMaxIssue(dirs));
      let id: string;
      if (existing) id = existing.id;
      else { const n = counters.get(cat)! + 1; counters.set(cat, n); id = `ISSUE-${String(n).padStart(2, '0')}`; }
      fc.issueId = id;
      const base = `[FAIL][${id}] ${caseName}`;

      const rec: IssueRecord = this.loadRecord(dirs, id) ?? { issueId: id, caseName, details: fc, history: [] };
      rec.details = fc;
      rec.caseName = caseName;
      rec.history.push({ status: 'FAIL', date: this.now() });

      this.removeIssueFiles(dirs, id, caseName);

      const shot = result.attachments.find((a) => a.name === 'screenshot' && a.path);
      if (shot?.path && fs.existsSync(shot.path)) {
        try { fs.copyFileSync(shot.path, path.join(dirs.image, `${base}.png`)); } catch {}
      }
      // API tests have no browser screenshot — render the request/response evidence into a PNG instead.
      const imgPath = path.join(dirs.image, `${base}.png`);
      if (!fs.existsSync(imgPath) && fc.apiEvidence) {
        await this.renderEvidencePng(fc.apiEvidence, imgPath);
      }
      // Visual regression (toHaveScreenshot): keep before / after / diff images.
      const visual: { before?: string; after?: string; diff?: string } = {};
      for (const [key, kw] of [['before', 'expected'], ['after', 'actual'], ['diff', 'diff']] as const) {
        const att = result.attachments.find(
          (a) => a.path && (a.contentType || '').includes('png') && (a.name || '').toLowerCase().includes(kw),
        );
        if (att?.path && fs.existsSync(att.path)) {
          const dest = path.join(dirs.image, `${base} -${key}.png`);
          try { fs.copyFileSync(att.path, dest); visual[key] = dest; } catch { /* ignore */ }
        }
      }
      if (visual.before || visual.after || visual.diff) fc.visual = visual;
      const vid = result.attachments.find((a) => a.name === 'video' && a.path);
      if (vid?.path && fs.existsSync(vid.path)) {
        try { fs.copyFileSync(vid.path, path.join(dirs.video, `${base}.webm`)); } catch {}
      }
      this.saveRecord(dirs, rec);

      if (docx) {
        try {
          const buf = await this.buildDocx(docx, fc, caseName, rec.history, 'FAIL', dirs);
          fs.writeFileSync(path.join(dirs.report, `${base}.docx`), buf);
        } catch (e) { console.log(`⚠️  Could not write docx for ${id}: ${e}`); }
      }

      const img = path.join(dirs.image, `${base}.png`);
      const mov = path.join(dirs.video, `${base}.webm`);
      fc.screenshot = fs.existsSync(img) ? img : undefined;
      fc.video = fs.existsSync(mov) ? mov : undefined;
      failures.push(fc);
      console.log(`❌ ${cat}/[FAIL][${id}] ${fc.funcSpec} - ${fc.title}`);
      console.log(`   Failed at step: ${fc.failedStep}`);
    }

    // --- passes: append history + flip prefix (every passing run for a known issue) ---
    for (const test of passCases) {
      const cat = this.category(test);
      const dirs = this.dirsFor(cat);
      if (!fs.existsSync(dirs.report)) continue;
      const caseName = this.sanitize(`${this.funcSpecName(test)} - ${test.title}`);
      const existing = this.findExistingIssue(dirs, caseName);
      if (!existing) continue;

      if (existing.status !== 'PASS') this.renameIssueStatus(dirs, existing.id, caseName, 'PASS');
      const rec = this.loadRecord(dirs, existing.id);
      if (rec) {
        rec.history.push({ status: 'PASS', date: this.now() });
        this.saveRecord(dirs, rec);
        if (docx) {
          try {
            const buf = await this.buildDocx(docx, rec.details, caseName, rec.history, 'PASS', dirs);
            fs.writeFileSync(path.join(dirs.report, `[PASS][${existing.id}] ${caseName}.docx`), buf);
          } catch {}
        }
        // If this test had a Jira ticket, move it forward (e.g. -> Committed).
        await resolveFixedTicket(rec.details);
        // Mirror on Asana / Azure DevOps / Basecamp: close/complete if open.
        await resolveFixedAsanaTask(rec.details);
        await resolveFixedAzureWorkItem(rec.details);
        await resolveFixedBasecampTodo(rec.details);
      }
      console.log(`✅ ${cat}/[PASS][${existing.id}] ${caseName}`);
    }

    console.log(`\n${summary}`);
    this.writeTestReport(byCat, { total, passed, failed });
    await createBugTickets(failures);
    await createAsanaTasks(failures);
    await createAzureWorkItems(failures);
    await createBasecampTodos(failures);
  }

  // ---------- category / dirs ----------
  private category(test: TestCase): string {
    // A run can force its category (BrowserStack reruns the UI/a11y specs but
    // we want those tickets tracked + labelled as "browserstack").
    if (process.env.BUG_CATEGORY_OVERRIDE) return process.env.BUG_CATEGORY_OVERRIDE;
    const f = test.location.file.replace(/\\/g, '/');
    const m = f.match(/\/tests\/([^/]+)\//);
    return m ? m[1] : 'other';
  }
  private dirsFor(cat: string): Dirs {
    const sub = cat;
    const report = path.join(this.bugReportDir, sub);
    return {
      report,
      image: path.join(this.bugImageDir, sub),
      video: path.join(this.bugVideoDir, sub),
      history: path.join(report, '.history'),
    };
  }
  private ensureDirs(d: Dirs): void {
    for (const p of [d.report, d.image, d.video, d.history]) fs.mkdirSync(p, { recursive: true });
  }

  /**
   * Write a run summary to test-report/ : total pass/fail per test type
   * (e2e / api / accessibility / chromatic / ...) plus the time it was created,
   * so you know when the run happened. One timestamped file per run.
   */
  private writeTestReport(
    byCat: Map<string, { total: number; passed: number; failed: number }>,
    totals: { total: number; passed: number; failed: number },
  ): void {
    try {
      // Folder mặc định "test-report"; CI + config BrowserStack đặt
      // TEST_REPORT_DIR=test-report-cloudbees-browserstack một cách tường minh.
      const dir = path.resolve(process.env.TEST_REPORT_DIR || 'test-report');
      fs.mkdirSync(dir, { recursive: true });
      const when = this.now(); // e.g. "2026-07-16 15:30 (GMT+7)"
      const stamp = when.replace(' (GMT+7)', '').replace(/[:\s]/g, '-'); // 2026-07-16-15-30
      const lines: string[] = [
        'HUB24 Automation — Test Report',
        `Generated: ${when}`,
        '',
        'By test type:',
      ];
      for (const [cat, t] of [...byCat.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
        lines.push(`  - ${cat}: total ${t.total} | pass ${t.passed} | fail ${t.failed}`);
      }
      lines.push('');
      lines.push(`TOTAL: ${totals.total} | Passed: ${totals.passed} | Failed: ${totals.failed}`);
      lines.push('');
      const file = path.join(dir, `test-report-${stamp}.txt`);
      fs.writeFileSync(file, lines.join('\n'), 'utf8');
      console.log(`\n📝 Test report saved -> ${file}`);
    } catch (e) {
      console.log(`⚠️  Could not write test report: ${e}`);
    }
  }

  // ---------- issue-id / file helpers ----------
  private sanitize(s: string): string {
    return strip(s).replace(/[\\/:*?"<>|]/g, '').replace(/\s+/g, ' ').replace(/\.+$/, '').trim().slice(0, 120);
  }
  private escapeRegex(s: string): string {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
  private now(): string {
    const parts = new Intl.DateTimeFormat('en-GB', {
      timeZone: 'Asia/Ho_Chi_Minh',
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit', hour12: false,
    }).formatToParts(new Date());
    const get = (t: string) => parts.find((p) => p.type === t)?.value ?? '';
    return `${get('year')}-${get('month')}-${get('day')} ${get('hour')}:${get('minute')} (GMT+7)`;
  }
  private currentMaxIssue(d: Dirs): number {
    let max = 0;
    for (const dir of [d.report, d.image, d.video]) {
      if (!fs.existsSync(dir)) continue;
      for (const f of fs.readdirSync(dir)) {
        const m = f.match(/\[ISSUE-(\d+)\]/);
        if (m) max = Math.max(max, parseInt(m[1], 10));
      }
    }
    return max;
  }
  private findExistingIssue(d: Dirs, caseName: string): { status: string; id: string } | null {
    const re = new RegExp(`^\\[(FAIL|PASS)\\]\\[(ISSUE-\\d+)\\] ${this.escapeRegex(caseName)}\\.(docx|png|webm)$`);
    for (const dir of [d.report, d.image, d.video]) {
      if (!fs.existsSync(dir)) continue;
      for (const f of fs.readdirSync(dir)) {
        const m = f.match(re);
        if (m) return { status: m[1], id: m[2] };
      }
    }
    return null;
  }
  private removeIssueFiles(d: Dirs, id: string, caseName: string): void {
    const re = new RegExp(`^\\[(FAIL|PASS)\\]\\[${this.escapeRegex(id)}\\] ${this.escapeRegex(caseName)}\\.(docx|png|webm)$`);
    for (const dir of [d.report, d.image, d.video]) {
      if (!fs.existsSync(dir)) continue;
      for (const f of fs.readdirSync(dir)) if (re.test(f)) { try { fs.unlinkSync(path.join(dir, f)); } catch {} }
    }
  }
  private renameIssueStatus(d: Dirs, id: string, caseName: string, newStatus: string): void {
    const re = new RegExp(`^\\[(FAIL|PASS)\\]\\[${this.escapeRegex(id)}\\] ${this.escapeRegex(caseName)}\\.(docx|png|webm)$`);
    for (const dir of [d.report, d.image, d.video]) {
      if (!fs.existsSync(dir)) continue;
      for (const f of fs.readdirSync(dir)) {
        if (!re.test(f)) continue;
        const renamed = f.replace(RE_ISSUE, `[${newStatus}][${id}]`);
        if (renamed !== f) { try { fs.renameSync(path.join(dir, f), path.join(dir, renamed)); } catch {} }
      }
    }
  }
  private loadRecord(d: Dirs, id: string): IssueRecord | null {
    const p = path.join(d.history, `${id}.json`);
    if (!fs.existsSync(p)) return null;
    try { return JSON.parse(fs.readFileSync(p, 'utf8')) as IssueRecord; } catch { return null; }
  }
  private saveRecord(d: Dirs, rec: IssueRecord): void {
    try { fs.writeFileSync(path.join(d.history, `${rec.issueId}.json`), JSON.stringify(rec, null, 2)); } catch {}
  }

  // ---------- failure data ----------
  private buildFailedCase(test: TestCase, result: TestResult): FailedCase {
    const rawReason =
      strip(result.errors.map((e) => e.message || '').join(' ')) ||
      strip(result.error?.message) || 'Unknown error';
    const reason = this.humanReason(rawReason);
    const { expected } = this.parseExpectedActual(rawReason);
    const actual = reason; // clear, human statement of what actually happened
    return {
      issueId: '',
      title: test.title,
      funcSpec: this.funcSpecName(test),
      suite: test.parent?.title || '',
      file: path.relative(process.cwd(), test.location.file),
      project: test.parent?.project()?.name ?? '',
      reason,
      failedStep: this.humanStep(this.findFailedStep(result.steps) ?? 'N/A'),
      stepsToReproduce: this.collectSteps(result.steps),
      actual,
      expected,
      apiEvidence: this.readAttachmentText(result, 'api-evidence'),
      chromaticUrl: this.category(test) === 'chromatic' ? this.chromaticBuildUrl() : undefined,
      browserstackUrl: (test.annotations ?? []).find((a) => a.type === 'browserstack-url')?.description,
      environment: this.environmentFor(test),
      parameters: (test.annotations ?? []).find((a) => a.type === 'test-parameters')?.description,
      severity: this.severityFor(test),
    };
  }
  /**
   * Best-guess severity label from the test's tags + category (QC to confirm):
   *   security -> blocker (P1) · smoke / e2e / api / accessibility -> critical (P2)
   *   visual (chromatic) -> minor (P4) · everything else -> major (P3).
   */
  private severityFor(test: TestCase): string {
    const tags = ((test as { tags?: string[] }).tags ?? []).map((t) => t.toLowerCase());
    const cat = this.category(test);
    if (tags.some((t) => t.includes('security'))) return 'P1-blocker';
    if (tags.some((t) => t.includes('smoke'))) return 'P2-critical';
    if (cat === 'accessibility' || cat === 'api' || cat === 'e2e') return 'P2-critical';
    if (cat === 'chromatic') return 'P4-minor';
    return 'P3-major';
  }
  /**
   * Where the test ran: device / OS / browser. Uses BrowserStack session
   * details when present (real device + OS); otherwise the local project name
   * + the runner OS (Desktop).
   */
  private environmentFor(test: TestCase): { device?: string; os?: string; browser?: string } {
    const ann = (t: string) => (test.annotations ?? []).find((a) => a.type === t)?.description;
    return {
      device: ann('bs-device') || 'Desktop',
      os: ann('bs-os') || this.localOs(),
      browser: this.browserFor(test),
    };
  }
  /** Local OS with version, e.g. "Windows 11 Pro" (Windows) or "macOS 23.6.0". */
  private localOs(): string {
    const map: Record<string, string> = { win32: 'Windows', darwin: 'macOS', linux: 'Linux' };
    try {
      const v = os.version(); // Windows returns a friendly "Windows 11 ..." string
      if (process.platform === 'win32' && v) return v;
      return `${map[process.platform] || process.platform} ${os.release()}`;
    } catch {
      return map[process.platform] || process.platform;
    }
  }
  /** The real browser (Chrome / Edge / Firefox / Safari), not the project name. */
  private browserFor(test: TestCase): string | undefined {
    // BrowserStack reports the real browser+version via annotation.
    const bs = (test.annotations ?? []).find((a) => a.type === 'bs-browser')?.description;
    if (bs) return bs;
    const use = test.parent?.project()?.use as
      | { browserName?: string; channel?: string; defaultBrowserType?: string }
      | undefined;
    if (use?.channel === 'msedge') return 'Edge';
    if (use?.channel === 'chrome') return 'Chrome';
    // Playwright devices set `defaultBrowserType`, not `browserName`.
    const bn = use?.browserName || use?.defaultBrowserType;
    const map: Record<string, string> = { chromium: 'Chrome', firefox: 'Firefox', webkit: 'Safari' };
    return bn ? map[bn] || bn : 'Chrome';
  }

  /**
   * Turn a raw Playwright error into a clear one-line reason. A custom assertion
   * message wins; otherwise name the element + what was expected (so tickets read
   * "Element not visible: [data-test=...]" instead of a generic "element not found").
   */
  /** A readable element name from a locator/step ("[data-test='login-button']" -> "login button"). */
  private elementName(s: string): string | null {
    const m =
      s.match(/data-test=["']?([^"'\])\s]+)/i) ||
      s.match(/getByRole\([^)]*name:\s*['"]([^'"]+)/i) ||
      s.match(/getBy\w+\(\s*['"]([^'"]+)['"]/i) ||
      s.match(/[#.]([A-Za-z][\w-]+)/);
    return m ? m[1].replace(/[-_]/g, ' ').trim() : null;
  }
  /**
   * Turn a raw Playwright error into a clear, human sentence a dev understands at
   * a glance. A custom assertion message wins; otherwise name the element + what
   * was expected — instead of a generic "element not found".
   */
  private humanReason(raw: string): string {
    // Accessibility (axe) violations: "[critical] select-name: <help> (N node(s))".
    const viol = [
      ...raw.matchAll(/\[(?:critical|serious|moderate|minor)\]\s+([\w-]+):\s+([^\n(]+?)\s*\(\d+\s*node/gi),
    ];
    if (viol.length) {
      const list = viol.slice(0, 4).map((m) => `${m[1]} (${m[2].trim()})`).join('; ');
      return `${viol.length} accessibility (WCAG) violation(s) found: ${list}${viol.length > 4 ? ' …' : ''}.`;
    }
    const first = (raw.replace(/^error:\s*/i, '').split('\n')[0] || '').trim();
    const boilerplate = /^(expect[\s(]|locator:|timed out|call log|received|expected|[-+]\s)/i.test(first);
    if (first && !boilerplate) return first; // custom message (e.g. "Header not found")
    if (/toHaveURL/i.test(raw)) return 'The page did not navigate to the expected URL.';
    const el = this.elementName(raw);
    if (el) {
      if (/toBeVisible/i.test(raw)) return `The "${el}" element was expected to be visible, but it was not found on the page.`;
      if (/toBeHidden/i.test(raw)) return `The "${el}" element was expected to be hidden, but it was still visible.`;
      if (/toHaveText/i.test(raw)) return `The "${el}" element did not show the expected text.`;
      if (/toHaveValue/i.test(raw)) return `The "${el}" field did not contain the expected value.`;
      if (/toHaveCount/i.test(raw)) return `The number of "${el}" elements did not match what was expected.`;
      return `The check on the "${el}" element did not pass.`;
    }
    return first || raw;
  }
  /** Rewrite a raw Playwright step title into a plain action a human understands. */
  private humanStep(title: string): string {
    const el = this.elementName(title);
    const nav = title.match(/Navigate to ["']([^"']+)["']/i);
    if (nav) return `Open the page ${nav[1]}`;
    const fill = title.match(/^Fill\s+["']([^"']*)["']/i);
    if (fill) {
      const secret = /pass(word)?|secret/i.test(el || '') || /pass(word)?|secret/i.test(title);
      return `Enter ${el || 'field'}: ${secret ? '***' : fill[1]}`;
    }
    if (/^(Press|Type)/i.test(title)) return `Type into the ${el || 'field'}`;
    if (/^(Click|Tap)/i.test(title)) return `Click the ${el || 'element'}`;
    if (/toBeVisible/i.test(title)) return `Check that the ${el || 'element'} is visible`;
    if (/toBeHidden/i.test(title)) return `Check that the ${el || 'element'} is hidden`;
    if (/toHaveText/i.test(title)) return `Check the ${el || 'element'} text`;
    if (/toHaveURL/i.test(title)) return 'Check the page URL';
    if (/toHaveValue/i.test(title)) return `Check the ${el || 'field'} value`;
    if (/toHaveCount/i.test(title)) return `Check the number of ${el || 'elements'}`;
    return title;
  }
  /** Chromatic build URL for linking visual changes (env or .chromatic-build-url file). */
  private chromaticBuildUrl(): string | undefined {
    if (process.env.CHROMATIC_BUILD_URL) return process.env.CHROMATIC_BUILD_URL;
    try {
      const p = path.resolve('.chromatic-build-url');
      if (fs.existsSync(p)) return fs.readFileSync(p, 'utf8').trim() || undefined;
    } catch { /* ignore */ }
    return undefined;
  }
  private readAttachmentText(result: TestResult, name: string): string | undefined {
    const a = result.attachments.find((x) => x.name === name);
    if (!a) return undefined;
    try {
      if (a.body) return strip(a.body.toString('utf8'));
      if (a.path && fs.existsSync(a.path)) return strip(fs.readFileSync(a.path, 'utf8'));
    } catch { /* ignore */ }
    return undefined;
  }
  /** Render plain text (API request/response) into a PNG using Playwright's chromium. */
  private async renderEvidencePng(text: string, outPath: string): Promise<boolean> {
    try {
      const { chromium } = await import('@playwright/test');
      const browser = await chromium.launch();
      try {
        const page = await browser.newPage({ viewport: { width: 900, height: 200 } });
        const esc = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        await page.setContent(
          `<pre style="font:13px/1.55 Consolas,Menlo,monospace;white-space:pre-wrap;` +
          `word-break:break-word;color:#111;background:#fff;margin:0;padding:16px">${esc}</pre>`,
        );
        await page.screenshot({ path: outPath, fullPage: true });
        return true;
      } finally { await browser.close(); }
    } catch { return false; }
  }
  private funcSpecName(test: TestCase): string {
    const describes: string[] = [];
    let s: unknown = test.parent;
    while (s && typeof s === 'object') {
      const suite = s as { type?: string; title?: string; parent?: unknown };
      if (suite.type === 'describe' && suite.title) describes.unshift(suite.title);
      s = suite.parent;
    }
    return describes[0] || test.parent?.title || 'Test';
  }
  private findFailedStep(steps: TestStep[]): string | null {
    for (const step of steps) {
      const nested = this.findFailedStep(step.steps);
      if (nested) return nested;
      if (step.error) return strip(step.title);
    }
    return null;
  }
  private hasErrorDeep(steps: TestStep[]): boolean {
    return steps.some((s) => s.error || this.hasErrorDeep(s.steps));
  }
  private collectSteps(steps: TestStep[], acc: { text: string; failed: boolean }[] = []): { text: string; failed: boolean }[] {
    for (const step of steps) {
      if (step.category === 'pw:api' || step.category === 'test.step' || step.category === 'expect') {
        // Drop Playwright plumbing steps that mean nothing to a reader.
        const infra = /create (browser )?context|create page|close (browser )?context|close page|new page|launch browser|^evaluate$/i.test(step.title.trim());
        if (!infra) {
          const failed = !!step.error && !this.hasErrorDeep(step.steps);
          const text = this.humanStep(strip(step.title)); // plain language
          const last = acc[acc.length - 1];
          if (!last || last.text !== text) acc.push({ text, failed });
          else if (failed) last.failed = true;
        }
      }
      this.collectSteps(step.steps, acc);
    }
    return acc;
  }
  private parseExpectedActual(msg: string): { actual: string; expected: string } {
    const expected = msg.match(/Expected:?\s*(.+?)(?:\s+Received:|\s*$)/i)?.[1]?.trim();
    const received = msg.match(/(?:Received|Actual):?\s*(.+)/i)?.[1]?.trim();
    return {
      expected: expected || 'The assertion should be satisfied and the test should pass.',
      actual: received || (msg.split('\n')[0] || 'See reason above.'),
    };
  }

  // ---------- docx (title has no status; status is on the filename) ----------
  private async buildDocx(
    docx: typeof import('docx'),
    f: FailedCase,
    caseName: string,
    history: HistoryEntry[],
    currentStatus: 'FAIL' | 'PASS',
    dirs: Dirs,
  ): Promise<Buffer> {
    const { Document, Packer, Paragraph, TextRun, HeadingLevel, ImageRun } = docx;
    const label = (t: string) => new TextRun({ text: t, bold: true });
    const c: InstanceType<typeof Paragraph>[] = [];

    c.push(new Paragraph({ text: `[${f.issueId}] ${f.funcSpec} - ${f.title}`, heading: HeadingLevel.TITLE }));
    c.push(new Paragraph({ children: [label('File: '), new TextRun(`${f.file}  (project: ${f.project})`)] }));
    if (f.severity) {
      c.push(new Paragraph({ children: [label('Severity: '), new TextRun(`${f.severity} — auto-assigned, QC to confirm`)] }));
    }
    c.push(new Paragraph({ children: [label('Reason (why it failed):')] }));
    c.push(new Paragraph({ text: f.reason }));
    c.push(new Paragraph({ children: [label('Failed at step: '), new TextRun(f.failedStep)] }));
    c.push(new Paragraph({ children: [label('Steps to reproduce:')] }));
    if (f.stepsToReproduce.length === 0) c.push(new Paragraph({ text: '(no steps recorded)' }));
    else f.stepsToReproduce.forEach((s, i) =>
      c.push(new Paragraph({ children: [new TextRun(`${i + 1}. ${s.failed ? '[FAILED] ' : ''}${s.text}`)] })));
    c.push(new Paragraph({ children: [label('Actual result (current): '), new TextRun(f.actual)] }));
    c.push(new Paragraph({ children: [label('Expected result (to pass): '), new TextRun(f.expected)] }));

    if (f.apiEvidence) {
      c.push(new Paragraph({ children: [label('API request / response:')] }));
      f.apiEvidence.split('\n').forEach((line) =>
        c.push(new Paragraph({ children: [new TextRun({ text: line || ' ', font: 'Consolas' })] })));
    }

    if (f.visual && (f.visual.before || f.visual.after || f.visual.diff)) {
      c.push(new Paragraph({ children: [label('Visual comparison:')] }));
      const shots: [keyof NonNullable<FailedCase['visual']>, string][] = [
        ['before', 'Before (expected)'], ['after', 'After (actual)'], ['diff', 'Diff'],
      ];
      for (const [k, cap] of shots) {
        const img = f.visual[k];
        if (img && fs.existsSync(img)) {
          c.push(new Paragraph({ text: cap }));
          try {
            c.push(new Paragraph({ children: [new ImageRun({ type: 'png', data: fs.readFileSync(img), transformation: { width: 600, height: 340 } } as never)] }));
          } catch { c.push(new Paragraph({ text: `(image: ${img})` })); }
        }
      }
    }
    if (f.chromaticUrl) {
      c.push(new Paragraph({ children: [label('Chromatic build: '), new TextRun(f.chromaticUrl)] }));
    }

    c.push(new Paragraph({ children: [label('Screenshot:')] }));
    const img = path.join(dirs.image, `[${currentStatus}][${f.issueId}] ${caseName}.png`);
    if (fs.existsSync(img)) {
      try {
        c.push(new Paragraph({ children: [new ImageRun({ type: 'png', data: fs.readFileSync(img), transformation: { width: 600, height: 340 } } as never)] }));
      } catch { c.push(new Paragraph({ text: `(image: ${img})` })); }
    } else c.push(new Paragraph({ text: '(no screenshot)' }));
    const vidName = `[${currentStatus}][${f.issueId}] ${caseName}.webm`;
    if (fs.existsSync(path.join(dirs.video, vidName)))
      c.push(new Paragraph({ children: [label('Video: '), new TextRun(vidName)] }));

    c.push(new Paragraph({ text: '' }));
    c.push(new Paragraph({ children: [label('Change history:')] }));
    if (history.length === 0) c.push(new Paragraph({ text: '(none)' }));
    else history.forEach((h) => c.push(new Paragraph({ text: `- ${h.status} on ${h.date}` })));

    return Packer.toBuffer(new Document({ sections: [{ children: c }] }));
  }
}
