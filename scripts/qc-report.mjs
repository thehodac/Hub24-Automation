/**
 * QC report generator — Report test results & coverage (backlog row 25).
 *
 * Pulls:
 *   - test results (pass / fail / total)  from  results/results.json  (Playwright JSON reporter)
 *   - open defects by severity (P1-P4)    from  Jira  (labels P1-blocker..P4-minor, non-Done)
 *   - test-case counts                    from  test-cases/**\/*.json
 * Then writes a report to  reports/qc-report.md  and evaluates the release exit criteria.
 *
 * Usage:  npm run qc:report
 * Needs (optional, for the defects section): JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN, JIRA_PROJECT_KEY.
 */
import fs from 'node:fs';
import path from 'node:path';

// --- tiny .env loader (only fills vars not already set) ---
try {
  for (const line of fs.readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !(m[1] in process.env)) process.env[m[1]] = m[2];
  }
} catch { /* no .env */ }

const SEVERITIES = ['P1-blocker', 'P2-critical', 'P3-major', 'P4-minor'];

// 1) Playwright results ------------------------------------------------------
// Aggregates EVERY results/*.json file, so a report can cover multiple suites
// (e2e / api / accessibility / visual) whether run together (test:all) or saved
// per-suite. Each suite's JSON stats are summed.
function testResults() {
  const dir = 'results';
  if (!fs.existsSync(dir)) return null;
  const files = fs.readdirSync(dir).filter((f) => f.endsWith('.json'));
  if (!files.length) return null;
  let passed = 0, failed = 0, flaky = 0, skipped = 0;
  for (const f of files) {
    try {
      const s = JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8')).stats || {};
      passed += s.expected || 0;
      failed += s.unexpected || 0;
      flaky += s.flaky || 0;
      skipped += s.skipped || 0;
    } catch { /* skip bad file */ }
  }
  const total = passed + failed + flaky + skipped;
  const passRate = total ? Math.round((passed / total) * 100) : 0;
  return { total, passed, failed, flaky, skipped, passRate, suites: files.length };
}

// 2) Open defects by severity (Jira) ----------------------------------------
async function defectCounts() {
  const base = (process.env.JIRA_BASE_URL || '').replace(/\/+$/, '');
  const email = process.env.JIRA_EMAIL;
  const token = process.env.JIRA_API_TOKEN;
  const proj = process.env.JIRA_PROJECT_KEY;
  if (!base || !email || !token || !proj) return null;
  const auth = 'Basic ' + Buffer.from(`${email}:${token}`).toString('base64');
  const counts = {};
  for (const label of SEVERITIES) {
    const jql = `project = "${proj}" AND labels = "${label}" AND statusCategory != Done`;
    const url = `${base}/rest/api/3/search/jql?jql=${encodeURIComponent(jql)}&maxResults=100&fields=key`;
    try {
      const r = await fetch(url, { headers: { Authorization: auth, Accept: 'application/json' } });
      counts[label] = r.ok ? (((await r.json()).issues) || []).length : null;
    } catch { counts[label] = null; }
  }
  return counts;
}

// 3) Test-case counts --------------------------------------------------------
function testCaseCounts() {
  const root = 'test-cases';
  if (!fs.existsSync(root)) return { features: 0, cases: 0 };
  let features = 0, cases = 0;
  const walk = (d) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) walk(p);
      else if (e.name.endsWith('.json')) {
        try {
          const arr = JSON.parse(fs.readFileSync(p, 'utf8'));
          if (Array.isArray(arr)) { features += 1; cases += arr.length; }
        } catch { /* skip */ }
      }
    }
  };
  walk(root);
  return { features, cases };
}

// --- build report -----------------------------------------------------------
const now = new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Asia/Ho_Chi_Minh', year: 'numeric', month: '2-digit', day: '2-digit',
  hour: '2-digit', minute: '2-digit', hour12: false,
}).format(new Date());

const tr = testResults();
const tc = testCaseCounts();
const def = await defectCounts();

const lines = [];
lines.push(`# QC Report — ${now} (GMT+7)`, '');

lines.push('## Test results');
if (tr) {
  lines.push(`- Total: **${tr.total}** · Passed: **${tr.passed}** · Failed: **${tr.failed}** · Flaky: ${tr.flaky} · Skipped: ${tr.skipped}`);
  lines.push(`- Pass rate: **${tr.passRate}%** (target 100%)`);
} else {
  lines.push('- _No results/results.json found — run the tests first (add the JSON reporter)._');
}
lines.push('');

lines.push('## Open defects by severity');
if (def) {
  for (const s of SEVERITIES) lines.push(`- ${s}: **${def[s] ?? 'n/a'}**`);
} else {
  lines.push('- _Jira credentials not set — skipped._');
}
lines.push('');

lines.push('## Test cases');
lines.push(`- Features: **${tc.features}** · Test cases: **${tc.cases}**`, '');

lines.push('## Release exit criteria');
const passOk = tr ? tr.failed === 0 && tr.total > 0 : false;
const p1 = def ? def['P1-blocker'] : null;
const p2 = def ? def['P2-critical'] : null;
const defOk = (def && p1 != null && p2 != null) ? (p1 === 0 && p2 === 0) : null;
lines.push(`- Pass rate 100% (0 failing): ${tr ? (passOk ? '✅' : '❌') : '—'}`);
lines.push(`- 0 open P1 & P2 defects: ${defOk === null ? '—' : (defOk ? '✅' : '❌')}`);
lines.push('- Coverage ≥ 80%: _to confirm against acceptance-criteria baseline_');
lines.push('');
lines.push('_Generated by scripts/qc-report.mjs. See QC Metrics & Reporting on Confluence for definitions._');

fs.mkdirSync('reports', { recursive: true });
fs.writeFileSync('reports/qc-report.md', lines.join('\n') + '\n');
console.log('Wrote reports/qc-report.md');
console.log(lines.join('\n'));
