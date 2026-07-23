/**
 * Auto-create Asana bug tasks from failed Playwright tests — mirrors jira.ts.
 * Runs in parallel with Jira; enable with ASANA_CREATE_TICKETS=true.
 *
 * Env (NEVER commit):
 *   ASANA_CREATE_TICKETS=true
 *   ASANA_TOKEN         Personal Access Token (app.asana.com → My Settings → Apps → Manage developer apps)
 *   ASANA_PROJECT_GID   target project GID (task is created in this project)
 *   ASANA_SECTION_GID   (optional) section GID within the project
 *
 * Flow: test fails  -> create task (with a "autobug-<hash>" marker in the notes).
 *       test passes -> that task is marked complete.
 * De-dup: a task with the same marker that is not completed is reused, not duplicated.
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import type { JiraBug } from './jira';
import { titlePrefix } from './jira';

const API = 'https://app.asana.com/api/1.0';

interface AsanaConfig {
  token: string;
  projectGid: string;
  sectionGid?: string;
}

function getConfig(): AsanaConfig | null {
  const token = process.env.ASANA_TOKEN;
  const projectGid = process.env.ASANA_PROJECT_GID;
  if (!token || !projectGid) return null;
  return { token, projectGid, sectionGid: process.env.ASANA_SECTION_GID || undefined };
}

function auth(cfg: AsanaConfig): Record<string, string> {
  return { Authorization: `Bearer ${cfg.token}` };
}

/** Stable marker per test so repeat failures reuse the same open task. */
function bugLabel(bug: JiraBug): string {
  const h = crypto.createHash('md5').update(`${bug.file}::${bug.title}`).digest('hex').slice(0, 10);
  return `autobug-${h}`;
}

/** "<prefix> <Func Spec Name> - <short bug description>" — same prefix rules as Jira. */
function taskName(bug: JiraBug): string {
  const spec = bug.funcSpec || bug.suite || 'Test';
  return `${titlePrefix(bug)} ${spec} - ${bug.title}`.slice(0, 240);
}

/** Plain-text notes body (Asana notes) mirroring the Jira description sections. */
function taskNotes(bug: JiraBug, label: string): string {
  const steps = bug.stepsToReproduce.length
    ? bug.stepsToReproduce.map((s, i) => `${i + 1}. ${s.failed ? '[FAILED HERE] ' : ''}${s.text}`).join('\n')
    : '(no steps recorded)';
  return [
    'Reason (why it failed)', bug.reason, '',
    'Failed at step', bug.failedStep, '',
    'Steps to reproduce', steps, '',
    'Actual result (current)', bug.actual, '',
    'Expected result (to pass)', bug.expected, '',
    (bug.environment && (bug.environment.device || bug.environment.os || bug.environment.browser))
      ? `Environment / Device: ${bug.environment.device ?? '-'} · OS: ${bug.environment.os ?? '-'} · Browser: ${bug.environment.browser ?? '-'}` : '',
    bug.parameters ? `Test parameters (user inputs): ${bug.parameters}` : '',
    `Test file: ${bug.file}`,
    bug.severity ? `Severity: ${bug.severity}` : '',
    bug.chromaticUrl ? `Chromatic build: ${bug.chromaticUrl}` : '',
    bug.browserstackUrl ? `BrowserStack session: ${bug.browserstackUrl}` : '',
    (bug.visual && (bug.visual.before || bug.visual.after)) ? 'Visual evidence: before + current (after) images attached.' : '',
    `Tracking: ${label}`,
    'Created automatically by the HUB24 Bug Report reporter.',
  ].filter((l) => l !== '').join('\n');
}

/** Best-effort: find an existing open (not completed) task carrying our marker. */
async function findExisting(cfg: AsanaConfig, label: string): Promise<string | null> {
  try {
    const url = `${API}/projects/${cfg.projectGid}/tasks?opt_fields=notes,completed&limit=100`;
    const res = await fetch(url, { headers: { ...auth(cfg), Accept: 'application/json' } });
    if (!res.ok) return null;
    const data = (await res.json()) as { data?: { gid: string; notes?: string; completed?: boolean }[] };
    const t = data.data?.find((x) => !x.completed && (x.notes || '').includes(label));
    return t?.gid ?? null;
  } catch {
    return null;
  }
}

async function createTask(cfg: AsanaConfig, bug: JiraBug, label: string): Promise<string> {
  const body = { data: { name: taskName(bug), notes: taskNotes(bug, label), projects: [cfg.projectGid] } };
  const res = await fetch(`${API}/tasks`, {
    method: 'POST',
    headers: { ...auth(cfg), Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`create task failed (${res.status}): ${await res.text()}`);
  const out = (await res.json()) as { data: { gid: string } };
  const gid = out.data.gid;
  if (cfg.sectionGid) {
    await fetch(`${API}/sections/${cfg.sectionGid}/addTask`, {
      method: 'POST',
      headers: { ...auth(cfg), Accept: 'application/json', 'Content-Type': 'application/json' },
      body: JSON.stringify({ data: { task: gid } }),
    }).catch(() => {});
  }
  return gid;
}

async function attachFile(cfg: AsanaConfig, gid: string, file: string): Promise<void> {
  if (!file || !fs.existsSync(file)) return;
  try {
    const form = new FormData();
    form.append('parent', gid);
    form.append('file', new Blob([fs.readFileSync(file)]), path.basename(file));
    await fetch(`${API}/attachments`, { method: 'POST', headers: { ...auth(cfg) }, body: form });
  } catch {
    /* best effort */
  }
}

/** Create Asana tasks for failed cases. No-op unless ASANA_CREATE_TICKETS=true + config present. */
export async function createAsanaTasks(bugs: JiraBug[]): Promise<void> {
  if (process.env.ASANA_CREATE_TICKETS !== 'true') return;
  if (bugs.length === 0) return;
  const cfg = getConfig();
  if (!cfg) {
    console.log('\n⚠️  ASANA_CREATE_TICKETS=true but Asana config missing (need ASANA_TOKEN, ASANA_PROJECT_GID). Skipping.');
    return;
  }
  console.log(`\n🗂️  Creating Asana tasks in project ${cfg.projectGid} ...`);
  for (const bug of bugs) {
    const label = bugLabel(bug);
    try {
      const existing = await findExisting(cfg, label);
      if (existing) {
        console.log(`   ↩︎  "${taskName(bug)}" already open as ${existing}, skipped.`);
        continue;
      }
      const gid = await createTask(cfg, bug, label);
      // Chromatic (visual): attach before + after images (no video); others: screenshot + video.
      if (bug.visual && (bug.visual.before || bug.visual.after)) {
        await attachFile(cfg, gid, bug.visual.before ?? '');
        await attachFile(cfg, gid, bug.visual.after ?? '');
      } else {
        await attachFile(cfg, gid, bug.screenshot ?? '');
        await attachFile(cfg, gid, bug.video ?? '');
      }
      console.log(`   ✅ Created Asana task ${gid} — ${taskName(bug)}`);
    } catch (e) {
      console.log(`   ❌ Failed to create Asana task for "${bug.title}": ${String(e)}`);
    }
  }
}

/** When a previously-failing test now passes, mark its Asana task complete. */
export async function resolveFixedAsanaTask(bug: JiraBug): Promise<void> {
  if (process.env.ASANA_CREATE_TICKETS !== 'true') return;
  const cfg = getConfig();
  if (!cfg) return;
  const label = bugLabel(bug);
  try {
    const gid = await findExisting(cfg, label);
    if (!gid) return;
    const res = await fetch(`${API}/tasks/${gid}`, {
      method: 'PUT',
      headers: { ...auth(cfg), Accept: 'application/json', 'Content-Type': 'application/json' },
      body: JSON.stringify({ data: { completed: true } }),
    });
    if (res.ok) console.log(`   ✅ Asana task ${gid} marked complete (test now passes).`);
    else console.log(`   ❌ Asana task ${gid}: complete failed (${res.status}).`);
  } catch (e) {
    console.log(`   ❌ Asana complete error for "${bug.title}": ${String(e)}`);
  }
}
