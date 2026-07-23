/**
 * Auto-create Azure DevOps work items (Bug) from failed Playwright tests —
 * mirrors jira.ts / asana.ts. Runs in parallel; enable with
 * AZURE_DEVOPS_CREATE_TICKETS=true.
 *
 * Env (NEVER commit):
 *   AZURE_DEVOPS_CREATE_TICKETS=true
 *   AZURE_DEVOPS_ORG        organization  (dev.azure.com/<org>)
 *   AZURE_DEVOPS_PROJECT    project name
 *   AZURE_DEVOPS_PAT        Personal Access Token (Work Items: Read & Write)
 *   AZURE_DEVOPS_AREA_PATH  (optional) area path
 *   AZURE_DEVOPS_PASS_STATE (optional) state to move a fixed item to, default "Closed"
 *
 * Dedup: a hidden tag `autobug-<hash>` (md5 of file + test title); an item with
 * that tag that is not Closed/Done is reused, not duplicated.
 */
import crypto from 'node:crypto';
import type { JiraBug } from './jira';

interface AdoConfig { org: string; project: string; pat: string; areaPath?: string; }

function getConfig(): AdoConfig | null {
  const org = process.env.AZURE_DEVOPS_ORG;
  const project = process.env.AZURE_DEVOPS_PROJECT;
  const pat = process.env.AZURE_DEVOPS_PAT;
  if (!org || !project || !pat) return null;
  return { org, project, pat, areaPath: process.env.AZURE_DEVOPS_AREA_PATH || undefined };
}
function auth(cfg: AdoConfig): string {
  return 'Basic ' + Buffer.from(`:${cfg.pat}`).toString('base64');
}
function bugTag(bug: JiraBug): string {
  const h = crypto.createHash('md5').update(`${bug.file}::${bug.title}`).digest('hex').slice(0, 10);
  return `autobug-${h}`;
}
function summary(bug: JiraBug): string {
  const spec = bug.funcSpec || bug.suite || 'Test';
  return `[Bug] ${spec} - ${bug.title}`.slice(0, 240);
}
function esc(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function descriptionHtml(bug: JiraBug): string {
  const p = (s: string) => `<p>${esc(s)}</p>`;
  const parts: string[] = [
    '<b>Reason (why it failed)</b>', p(bug.reason),
    '<b>Failed at step</b>', p(bug.failedStep),
    '<b>Steps to reproduce</b>',
    '<ol>' + bug.stepsToReproduce.map((s) => `<li>${s.failed ? '[FAILED HERE] ' : ''}${esc(s.text)}</li>`).join('') + '</ol>',
    '<b>Actual result</b>', p(bug.actual),
    '<b>Expected result</b>', p(bug.expected),
  ];
  if (bug.environment && (bug.environment.device || bug.environment.os || bug.environment.browser)) {
    parts.push('<b>Environment / Device</b>', p(`Device: ${bug.environment.device ?? '-'} · OS: ${bug.environment.os ?? '-'} · Browser: ${bug.environment.browser ?? '-'}`));
  }
  if (bug.parameters) parts.push('<b>Test parameters (user inputs)</b>', p(bug.parameters));
  if (bug.browserstackUrl) parts.push(p(`BrowserStack session: ${bug.browserstackUrl}`));
  if (bug.chromaticUrl) parts.push(p(`Chromatic build: ${bug.chromaticUrl}`));
  parts.push(p(`Test file: ${bug.file}`), p('Created automatically by the HUB24 Bug Report reporter.'));
  return parts.join('');
}
const api = (cfg: AdoConfig, part: string) =>
  `https://dev.azure.com/${encodeURIComponent(cfg.org)}/${encodeURIComponent(cfg.project)}/_apis/${part}`;

/** Find an existing open work item carrying our tag. Returns id or null. */
async function findExisting(cfg: AdoConfig, tag: string): Promise<string | null> {
  try {
    const wiql =
      `SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = @project ` +
      `AND [System.Tags] CONTAINS '${tag}' AND [System.State] <> 'Closed' AND [System.State] <> 'Done' ` +
      `ORDER BY [System.CreatedDate] DESC`;
    const res = await fetch(api(cfg, 'wit/wiql?api-version=7.0'), {
      method: 'POST',
      headers: { Authorization: auth(cfg), 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify({ query: wiql }),
    });
    if (!res.ok) return null;
    const data = (await res.json()) as { workItems?: { id: number }[] };
    return data.workItems?.[0]?.id ? String(data.workItems[0].id) : null;
  } catch {
    return null;
  }
}

async function createWorkItem(cfg: AdoConfig, bug: JiraBug, tag: string): Promise<string> {
  const ops: unknown[] = [
    { op: 'add', path: '/fields/System.Title', value: summary(bug) },
    { op: 'add', path: '/fields/System.Description', value: descriptionHtml(bug) },
    { op: 'add', path: '/fields/System.Tags', value: `automation; ${tag}${bug.severity ? '; ' + bug.severity : ''}` },
  ];
  if (cfg.areaPath) ops.push({ op: 'add', path: '/fields/System.AreaPath', value: cfg.areaPath });
  const res = await fetch(api(cfg, 'wit/workitems/$Bug?api-version=7.0'), {
    method: 'POST',
    headers: { Authorization: auth(cfg), 'Content-Type': 'application/json-patch+json', Accept: 'application/json' },
    body: JSON.stringify(ops),
  });
  if (!res.ok) throw new Error(`create work item failed (${res.status}): ${await res.text()}`);
  const data = (await res.json()) as { id: number };
  return String(data.id);
}

/** Create Azure DevOps work items for failed cases. No-op unless enabled + configured. */
export async function createAzureWorkItems(bugs: JiraBug[]): Promise<void> {
  if (process.env.AZURE_DEVOPS_CREATE_TICKETS !== 'true') return;
  if (bugs.length === 0) return;
  const cfg = getConfig();
  if (!cfg) {
    console.log('\n⚠️  AZURE_DEVOPS_CREATE_TICKETS=true but config missing (need AZURE_DEVOPS_ORG, AZURE_DEVOPS_PROJECT, AZURE_DEVOPS_PAT). Skipping.');
    return;
  }
  console.log(`\n🔷 Creating Azure DevOps work items in ${cfg.org}/${cfg.project} ...`);
  for (const bug of bugs) {
    const tag = bugTag(bug);
    try {
      const existing = await findExisting(cfg, tag);
      if (existing) { console.log(`   ↩︎  "${summary(bug)}" already open as #${existing}, skipped.`); continue; }
      const id = await createWorkItem(cfg, bug, tag);
      console.log(`   ✅ Created work item #${id} — ${summary(bug)}`);
    } catch (e) {
      console.log(`   ❌ Failed to create Azure work item for "${bug.title}": ${String(e)}`);
    }
  }
}

/** When a previously-failing test now passes, move its work item to Closed (or AZURE_DEVOPS_PASS_STATE). */
export async function resolveFixedAzureWorkItem(bug: JiraBug): Promise<void> {
  if (process.env.AZURE_DEVOPS_CREATE_TICKETS !== 'true') return;
  const cfg = getConfig();
  if (!cfg) return;
  const target = process.env.AZURE_DEVOPS_PASS_STATE || 'Closed';
  try {
    const id = await findExisting(cfg, bugTag(bug));
    if (!id) return;
    const res = await fetch(api(cfg, `wit/workitems/${id}?api-version=7.0`), {
      method: 'PATCH',
      headers: { Authorization: auth(cfg), 'Content-Type': 'application/json-patch+json', Accept: 'application/json' },
      body: JSON.stringify([{ op: 'add', path: '/fields/System.State', value: target }]),
    });
    if (res.ok) console.log(`   ✅ Azure work item #${id} → "${target}" (test now passes).`);
    else console.log(`   ❌ Azure #${id}: state change failed (${res.status}).`);
  } catch (e) {
    console.log(`   ❌ Azure resolve error for "${bug.title}": ${String(e)}`);
  }
}
