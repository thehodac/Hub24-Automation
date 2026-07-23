/**
 * Run Chromatic and, IF the build has visual changes, auto-create a ticket
 * (Jira and/or Asana) that includes:
 *   - the Chromatic BUILD NUMBER and build URL,
 *   - the EXACT URL of each changed page/story,
 *   - the BEFORE and AFTER images (attached to the ticket).
 *
 * Usage:  npm run chromatic:ticket        (needs CHROMATIC_PROJECT_TOKEN)
 * Enable ticket creation with the same env flags as the bug reporter:
 *   JIRA_CREATE_TICKETS=true  (+ JIRA_BASE_URL/EMAIL/API_TOKEN/PROJECT_KEY/PARENT_KEY)
 *   ASANA_CREATE_TICKETS=true (+ ASANA_TOKEN/PROJECT_GID)
 *
 * Before/after + per-page URL come from the Chromatic API (GraphQL). If that
 * lookup fails, the ticket is still created with the build number + build URL,
 * and the raw API response is logged so the query can be refined.
 *   CHROMATIC_API_URL   (optional) default https://index.chromatic.com/graphql
 *   CHROMATIC_API_TOKEN (optional) defaults to CHROMATIC_PROJECT_TOKEN
 *
 * De-dup: one ticket per build number (marker "chromatic-build-<N>").
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

// --- tiny .env loader ---
try {
  for (const line of fs.readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !(m[1] in process.env)) process.env[m[1]] = m[2];
  }
} catch { /* no .env */ }

// --- 1) run Chromatic, capture output ---
function runChromatic(extra = []) {
  return new Promise((resolve) => {
    const c = spawn('npx', ['chromatic', '--playwright', ...extra], { shell: true });
    let out = '';
    const cap = (d) => { const s = d.toString(); out += s; process.stdout.write(s); };
    c.stdout.on('data', cap);
    c.stderr.on('data', cap);
    c.on('close', (code) => resolve({ code: code ?? 0, out }));
  });
}

console.log('\n▶  Running Chromatic ...');
const { out } = await runChromatic(['--exit-zero-on-changes']);

const urlMatch = out.match(/https:\/\/www\.chromatic\.com\/build\?[^\s"]+/);
const buildUrl = urlMatch ? urlMatch[0] : '';
if (buildUrl) fs.writeFileSync('.chromatic-build-url', buildUrl);
const appId = (buildUrl.match(/[?&]appId=([^&]+)/) || [])[1] || '';
const buildNumber = (buildUrl.match(/[?&]number=(\d+)/) || out.match(/[Bb]uild\s+(\d+)/) || [])[1] || '?';
const changeMatch = out.match(/(\d+)\s+change(?:s)?\b/i);
const changeCount = changeMatch ? Number(changeMatch[1]) : (/\bno changes\b/i.test(out) ? 0 : null);

console.log(`\n📦 Chromatic build #${buildNumber} · changes: ${changeCount ?? 'unknown'}`);
if (!changeCount || changeCount <= 0) {
  console.log('✅ No visual changes to review — no ticket created.');
  process.exit(0);
}

// --- 2) fetch changed pages (name, URL, before/after image URLs) from Chromatic API ---
async function fetchChanges() {
  const endpoint = process.env.CHROMATIC_API_URL || 'https://index.chromatic.com/graphql';
  const token = process.env.CHROMATIC_API_TOKEN || process.env.CHROMATIC_PROJECT_TOKEN;
  if (!token || !appId || buildNumber === '?') return [];
  const query = `query($appId: ObjID!, $number: Int!) {
    app(id: $appId) {
      build(number: $number) {
        tests {
          nodes {
            status
            webUrl
            story { name component { name } }
            comparisons {
              baseCapture { captureImage { imageUrl } }
              headCapture { captureImage { imageUrl } }
            }
          }
        }
      }
    }
  }`;
  try {
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify({ query, variables: { appId, number: Number(buildNumber) } }),
    });
    const text = await res.text();
    if (!res.ok) { console.log(`(Chromatic API ${res.status}) — share this to refine the query:\n${text.slice(0, 600)}`); return []; }
    const data = JSON.parse(text);
    const nodes = data?.data?.app?.build?.tests?.nodes || [];
    const changes = nodes
      .filter((n) => String(n.status || '').toUpperCase().includes('CHANGE') || (n.comparisons || []).length)
      .map((n) => {
        const cmp = (n.comparisons || [])[0] || {};
        const name = [n.story?.component?.name, n.story?.name].filter(Boolean).join(' / ') || 'page';
        return {
          name,
          webUrl: n.webUrl || buildUrl,
          before: cmp.baseCapture?.captureImage?.imageUrl || '',
          after: cmp.headCapture?.captureImage?.imageUrl || '',
        };
      });
    if (!changes.length) console.log('(Chromatic API returned no change details — ticket will use build # + URL only.)');
    return changes;
  } catch (e) {
    console.log(`(Chromatic API lookup failed: ${String(e)} — ticket will use build # + URL only.)`);
    return [];
  }
}

async function download(url) {
  if (!url) return null;
  try {
    const r = await fetch(url);
    if (!r.ok) return null;
    return Buffer.from(await r.arrayBuffer());
  } catch { return null; }
}

const changes = await fetchChanges();

// download before/after images to a temp folder so they can be attached
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'chromatic-'));
const attachments = [];
for (let i = 0; i < changes.length; i++) {
  const c = changes[i];
  const b = await download(c.before);
  const a = await download(c.after);
  if (b) { const p = path.join(tmp, `change${i + 1}-before.png`); fs.writeFileSync(p, b); attachments.push(p); }
  if (a) { const p = path.join(tmp, `change${i + 1}-after.png`); fs.writeFileSync(p, a); attachments.push(p); }
}

// --- ticket content ---
const summary = `[Visual] Chromatic build #${buildNumber} — ${changeCount} change(s) to review`;
const marker = `chromatic-build-${buildNumber}`;
const bodyLines = [
  `Chromatic build #${buildNumber} has ${changeCount} visual change(s) that need review.`,
  '',
  `Build: ${buildUrl || '(URL not captured)'}`,
];
if (changes.length) {
  bodyLines.push('', 'Changed pages:');
  changes.forEach((c, i) => bodyLines.push(`${i + 1}. ${c.name} — ${c.webUrl}`));
  bodyLines.push('', 'Before/after images are attached to this ticket.');
}
bodyLines.push('', 'What to do: open the build on Chromatic, review each change, then Accept (intended) or Deny (regression).',
  `Tracking: ${marker}`, 'Created automatically by the HUB24 visual-regression → ticket script.');

// --- Jira ---
async function jiraAttach(base, H, key, file) {
  try {
    const form = new FormData();
    form.append('file', new Blob([fs.readFileSync(file)]), path.basename(file));
    await fetch(`${base}/rest/api/3/issue/${key}/attachments`, {
      method: 'POST', headers: { Authorization: H.Authorization, 'X-Atlassian-Token': 'no-check' }, body: form,
    });
  } catch {}
}
async function createJira() {
  if (process.env.JIRA_CREATE_TICKETS !== 'true') return;
  const base = (process.env.JIRA_BASE_URL || '').replace(/\/+$/, '');
  const email = process.env.JIRA_EMAIL, token = process.env.JIRA_API_TOKEN, proj = process.env.JIRA_PROJECT_KEY;
  const parent = process.env.JIRA_PARENT_KEY || process.env.JIRA_EPIC_KEY;
  if (!base || !email || !token || !proj) { console.log('⚠️  Jira creds missing — skipping Jira.'); return; }
  const auth = 'Basic ' + Buffer.from(`${email}:${token}`).toString('base64');
  const H = { Authorization: auth, Accept: 'application/json', 'Content-Type': 'application/json' };
  try {
    const jql = `project = "${proj}" AND labels = "${marker}" AND statusCategory != Done`;
    const r = await fetch(`${base}/rest/api/3/search/jql?jql=${encodeURIComponent(jql)}&maxResults=1&fields=key`, { headers: H });
    if (r.ok) { const d = await r.json(); if (d.issues?.[0]?.key) { console.log(`↩︎  Jira already open for build #${buildNumber}: ${d.issues[0].key}`); return; } }
  } catch {}
  let issueType = process.env.JIRA_ISSUE_TYPE || 'Bug';
  if (parent) {
    try {
      const r = await fetch(`${base}/rest/api/3/issue/${parent}?fields=issuetype`, { headers: H });
      if (r.ok) { const it = (await r.json()).fields?.issuetype;
        if (it && it.name !== 'Epic' && !(typeof it.hierarchyLevel === 'number' && it.hierarchyLevel >= 1))
          issueType = process.env.JIRA_SUBTASK_TYPE || 'Bug Fixing (in-sprint) Sub-task'; }
    } catch {}
  }
  const description = { type: 'doc', version: 1, content: [
    { type: 'heading', attrs: { level: 3 }, content: [{ type: 'text', text: 'Visual changes detected' }] },
    ...bodyLines.map((t) => ({ type: 'paragraph', content: t ? [{ type: 'text', text: t }] : [] })),
  ] };
  const fields = { project: { key: proj }, summary, issuetype: { name: issueType },
    labels: ['automation', 'chromatic', 'P4-minor', marker], description };
  if (parent) fields.parent = { key: parent };
  const res = await fetch(`${base}/rest/api/3/issue`, { method: 'POST', headers: H, body: JSON.stringify({ fields }) });
  if (!res.ok) { console.log(`❌ Jira create failed (${res.status}): ${await res.text()}`); return; }
  const key = (await res.json()).key;
  for (const f of attachments) await jiraAttach(base, H, key, f);
  console.log(`✅ Jira ticket created: ${key} — ${summary}${attachments.length ? ` (+${attachments.length} images)` : ''}`);
}

// --- Asana ---
async function createAsana() {
  if (process.env.ASANA_CREATE_TICKETS !== 'true') return;
  const token = process.env.ASANA_TOKEN, projectGid = process.env.ASANA_PROJECT_GID;
  if (!token || !projectGid) { console.log('⚠️  Asana config missing — skipping Asana.'); return; }
  const H = { Authorization: `Bearer ${token}`, Accept: 'application/json', 'Content-Type': 'application/json' };
  try {
    const r = await fetch(`https://app.asana.com/api/1.0/projects/${projectGid}/tasks?opt_fields=notes,completed&limit=100`, { headers: H });
    if (r.ok) { const d = await r.json(); const t = d.data?.find((x) => !x.completed && (x.notes || '').includes(marker));
      if (t) { console.log(`↩︎  Asana already open for build #${buildNumber}: ${t.gid}`); return; } }
  } catch {}
  const body = { data: { name: summary, notes: bodyLines.join('\n'), projects: [projectGid] } };
  const res = await fetch('https://app.asana.com/api/1.0/tasks', { method: 'POST', headers: H, body: JSON.stringify(body) });
  if (!res.ok) { console.log(`❌ Asana create failed (${res.status}): ${await res.text()}`); return; }
  const gid = (await res.json()).data.gid;
  for (const f of attachments) {
    try { const form = new FormData(); form.append('parent', gid);
      form.append('file', new Blob([fs.readFileSync(f)]), path.basename(f));
      await fetch('https://app.asana.com/api/1.0/attachments', { method: 'POST', headers: { Authorization: `Bearer ${token}` }, body: form });
    } catch {}
  }
  console.log(`✅ Asana task created: ${gid} — ${summary}${attachments.length ? ` (+${attachments.length} images)` : ''}`);
}

await createJira();
await createAsana();
