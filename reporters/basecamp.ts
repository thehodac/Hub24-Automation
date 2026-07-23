/**
 * Auto-create Basecamp 3 to-dos from failed Playwright tests — mirrors
 * jira.ts / asana.ts. Runs in parallel; enable with BASECAMP_CREATE_TICKETS=true.
 *
 * Env (NEVER commit):
 *   BASECAMP_CREATE_TICKETS=true
 *   BASECAMP_TOKEN        OAuth2 access token
 *   BASECAMP_ACCOUNT_ID   account id  (3.basecampapi.com/<id>)
 *   BASECAMP_PROJECT_ID   project / bucket id
 *   BASECAMP_TODOLIST_ID  to-do list id (where the to-dos are created)
 *
 * Dedup: a marker `autobug-<hash>` is written into the to-do's description; an
 * incomplete to-do carrying that marker is reused, not duplicated.
 * Test passes again -> the to-do is marked complete.
 */
import crypto from 'node:crypto';
import type { JiraBug } from './jira';

interface BcConfig { token: string; account: string; project: string; todolist: string; }

function getConfig(): BcConfig | null {
  const token = process.env.BASECAMP_TOKEN;
  const account = process.env.BASECAMP_ACCOUNT_ID;
  const project = process.env.BASECAMP_PROJECT_ID;
  const todolist = process.env.BASECAMP_TODOLIST_ID;
  if (!token || !account || !project || !todolist) return null;
  return { token, account, project, todolist };
}
function headers(cfg: BcConfig): Record<string, string> {
  return {
    Authorization: `Bearer ${cfg.token}`,
    'Content-Type': 'application/json',
    Accept: 'application/json',
    // Basecamp requires an identifying User-Agent.
    'User-Agent': 'HUB24 Automation (technical@theprojectfactory.com)',
  };
}
function marker(bug: JiraBug): string {
  const h = crypto.createHash('md5').update(`${bug.file}::${bug.title}`).digest('hex').slice(0, 10);
  return `autobug-${h}`;
}
function title(bug: JiraBug): string {
  const spec = bug.funcSpec || bug.suite || 'Test';
  return `[Bug] ${spec} - ${bug.title}`.slice(0, 240);
}
function esc(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function bodyHtml(bug: JiraBug, mk: string): string {
  const lines: string[] = [
    `Reason: ${bug.reason}`,
    `Failed at step: ${bug.failedStep}`,
    'Steps: ' + bug.stepsToReproduce.map((s, i) => `${i + 1}. ${s.failed ? '[FAILED] ' : ''}${s.text}`).join(' | '),
    `Actual: ${bug.actual}`,
    `Expected: ${bug.expected}`,
  ];
  if (bug.environment && (bug.environment.device || bug.environment.os || bug.environment.browser)) {
    lines.push(`Environment / Device: Device ${bug.environment.device ?? '-'} · OS ${bug.environment.os ?? '-'} · Browser ${bug.environment.browser ?? '-'}`);
  }
  if (bug.parameters) lines.push(`Test parameters: ${bug.parameters}`);
  if (bug.browserstackUrl) lines.push(`BrowserStack session: ${bug.browserstackUrl}`);
  if (bug.chromaticUrl) lines.push(`Chromatic build: ${bug.chromaticUrl}`);
  lines.push(`Test file: ${bug.file}`, `Tracking: ${mk}`, 'Created automatically by the HUB24 Bug Report reporter.');
  return lines.map((l) => `<div>${esc(l)}</div>`).join('');
}
const base = (cfg: BcConfig, p: string) => `https://3.basecampapi.com/${cfg.account}/${p}`;

/** Find an incomplete to-do carrying our marker. Returns id or null. */
async function findExisting(cfg: BcConfig, mk: string): Promise<string | null> {
  try {
    const res = await fetch(base(cfg, `buckets/${cfg.project}/todolists/${cfg.todolist}/todos.json?completed=false`), { headers: headers(cfg) });
    if (!res.ok) return null;
    const data = (await res.json()) as { id: number; description?: string }[];
    const t = data.find((x) => (x.description || '').includes(mk));
    return t ? String(t.id) : null;
  } catch {
    return null;
  }
}
async function createTodo(cfg: BcConfig, bug: JiraBug, mk: string): Promise<string> {
  const res = await fetch(base(cfg, `buckets/${cfg.project}/todolists/${cfg.todolist}/todos.json`), {
    method: 'POST',
    headers: headers(cfg),
    body: JSON.stringify({ content: title(bug), description: bodyHtml(bug, mk) }),
  });
  if (!res.ok) throw new Error(`create to-do failed (${res.status}): ${await res.text()}`);
  const data = (await res.json()) as { id: number };
  return String(data.id);
}

/** Create Basecamp to-dos for failed cases. No-op unless enabled + configured. */
export async function createBasecampTodos(bugs: JiraBug[]): Promise<void> {
  if (process.env.BASECAMP_CREATE_TICKETS !== 'true') return;
  if (bugs.length === 0) return;
  const cfg = getConfig();
  if (!cfg) {
    console.log('\n⚠️  BASECAMP_CREATE_TICKETS=true but config missing (need BASECAMP_TOKEN, BASECAMP_ACCOUNT_ID, BASECAMP_PROJECT_ID, BASECAMP_TODOLIST_ID). Skipping.');
    return;
  }
  console.log(`\n🧷 Creating Basecamp to-dos in project ${cfg.project} ...`);
  for (const bug of bugs) {
    const mk = marker(bug);
    try {
      const existing = await findExisting(cfg, mk);
      if (existing) { console.log(`   ↩︎  "${title(bug)}" already open as ${existing}, skipped.`); continue; }
      const id = await createTodo(cfg, bug, mk);
      console.log(`   ✅ Created Basecamp to-do ${id} — ${title(bug)}`);
    } catch (e) {
      console.log(`   ❌ Failed to create Basecamp to-do for "${bug.title}": ${String(e)}`);
    }
  }
}

/** When a previously-failing test now passes, mark its Basecamp to-do complete. */
export async function resolveFixedBasecampTodo(bug: JiraBug): Promise<void> {
  if (process.env.BASECAMP_CREATE_TICKETS !== 'true') return;
  const cfg = getConfig();
  if (!cfg) return;
  try {
    const id = await findExisting(cfg, marker(bug));
    if (!id) return;
    const res = await fetch(base(cfg, `buckets/${cfg.project}/todos/${id}/completion.json`), { method: 'POST', headers: headers(cfg) });
    if (res.ok || res.status === 204) console.log(`   ✅ Basecamp to-do ${id} completed (test now passes).`);
    else console.log(`   ❌ Basecamp to-do ${id}: complete failed (${res.status}).`);
  } catch (e) {
    console.log(`   ❌ Basecamp resolve error for "${bug.title}": ${String(e)}`);
  }
}
