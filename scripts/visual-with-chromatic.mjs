/**
 * One command for visual testing WITH a Chromatic build link in the report.
 *
 * Chromatic only knows the build URL after upload, but the local bug report is
 * generated DURING the Playwright run — so we:
 *   1) run the visual test  (produces Chromatic archives + local diff report),
 *   2) upload to Chromatic   (creates a new build, capture + save the URL),
 *   3) run the visual test again (report now includes the Chromatic link).
 *
 * Usage:  npm run test:visual:chromatic     (needs CHROMATIC_PROJECT_TOKEN)
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';

// Load .env into process.env so the child processes (Chromatic upload, tests)
// receive CHROMATIC_PROJECT_TOKEN / JIRA_* / ASANA_* .
try {
  for (const line of fs.readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !(m[1] in process.env)) process.env[m[1]] = m[2];
  }
} catch { /* no .env */ }

function run(cmd, args, env) {
  return new Promise((resolve) => {
    const c = spawn(cmd, args, { shell: true, env: { ...process.env, ...(env || {}) } });
    let out = '';
    const cap = (d) => { const s = d.toString(); out += s; process.stdout.write(s); };
    c.stdout.on('data', cap);
    c.stderr.on('data', cap);
    c.on('close', (code) => resolve({ code: code ?? 0, out }));
  });
}

const VISUAL = ['playwright', 'test', '--project=visual'];

// Run 1: produce the Chromatic archives + local snapshots, but DO NOT create
// tickets yet (the Chromatic build URL isn't known until after the upload).
console.log('\n[1/3] Running visual test (archives only, tickets OFF) ...');
await run('npx', VISUAL, { JIRA_CREATE_TICKETS: 'false', ASANA_CREATE_TICKETS: 'false' });

console.log('\n[2/3] Uploading to Chromatic (new build) ...');
if (!process.env.CHROMATIC_PROJECT_TOKEN) {
  console.log('⚠️  CHROMATIC_PROJECT_TOKEN not set in env/.env — Chromatic cannot upload a build.');
}
// --force-rebuild: always create a NEW build, even if the commit is unchanged
// (Chromatic skips rebuilds of an already passed/accepted commit by default).
const chromatic = await run('npx', ['chromatic', '--playwright', '--exit-zero-on-changes', '--force-rebuild']);
const m = chromatic.out.match(/https:\/\/www\.chromatic\.com\/build\?[^\s"]+/);
if (m) {
  fs.writeFileSync('.chromatic-build-url', m[0]);
  console.log('\n✅ Chromatic build created ->', m[0]);
  console.log('   (Open this exact URL — it points to the right project/build.)');
} else {
  console.log(`\n❌ No Chromatic build URL detected (chromatic exit code ${chromatic.code}).`);
  console.log('   Check the Chromatic lines above for the reason (token / project / no archives).');
  console.log('   Tip: run "npm run chromatic" alone to see the full Chromatic output.');
}

// Run 3: now the Chromatic build URL is saved, so this run's reporter creates
// the ticket WITH the build link + before/after images (tickets use .env flags).
console.log('\n[3/3] Re-running visual test — tickets ON, includes Chromatic build link + before/after ...');
const last = await run('npx', VISUAL);
process.exit(last.code);
